namespace :mesh do
  desc "Removes all MeSH terms from the mesh_keywords table"
  task :purge => :environment do
    puts "Purging database of all existing MeSH Terms"
    MeshKeyword.delete_all
  end
  
  desc "Seeds MeSH terms from the MeshKeywordLookup module"
  task :seed_database => [:environment, :purge] do
    # Force-reload MeshKeywordLookup
    Object.class_eval do
      remove_const 'MeshKeywordLookup' if const_defined? 'MeshKeywordLookup'
    end
    require 'mesh_keyword_lookup'
    require 'progressbar'
    
    puts "Loading MeSH terms from mesh_keyword_lookup"
    pbar = ProgressBar.new("loading", MeshKeywordLookup.length)
    MeshKeywordLookup.each do |name, id|
      pbar.inc
      sql = MeshKeyword.send(:sanitize_sql, ["INSERT INTO `#{MeshKeyword.table_name}` (`created_at`, `updated_at`, `id`, `name`) VALUES(NOW(), NOW(), #{id}, '%s')", name.titleize])      
      MeshKeyword.connection.execute(sql)
    end
    pbar.finish
  end
  
  desc "Creates MeSH indexes from file"
  task :create_indexes, [:filename] => [:environment] do |t, args|
    
    abort "You must pass in the name of a file to load,\n"+
          " Example: rake mesh:create_indexes[./mh_freq_count]" unless File.exists?(args.filename)
    
    keyword_lookup = {}
    count_lookup   = {}
    
    max_mesh_count = 0
    
    File.open(args.filename) do |f|
      f.each_line do |line|
        next if line.strip.blank?
        
        # TODO: Update the line below to reflect the real columns when those are known
        count, 
        count_when_starred, 
        count_without_subheading, 
        count_with_subheading, 
        mesh_heading,
        mesh_id = line.strip.split('|')
        
        # Manipulate desired columns as necessary
        count        = count.to_i
        mesh_heading = mesh_heading.upcase
        mesh_id      = mesh_id.to_i # TODO this will probably need to be updated given the real mh_freq_count

        # Check for errors in data and abort if necessary
        abort "Detected blank MeSH Descriptor in line '#{line.inspect}'" if mesh_heading.blank? 
        abort "Detected invalid MeSH ID number in line '#{line.inspect}'" if mesh_id == 0
        
        max_mesh_count = count if count > max_mesh_count
        keyword_lookup[mesh_heading] = mesh_id
        count_lookup[mesh_id] = count
      end
    end
    
    # Convert raw counts to a score
    max_mesh_count = max_mesh_count.to_f # Make sure division below is done with floats
    count_lookup.each do |mesh_id, count|
      count_lookup[mesh_id] = count / max_mesh_count
    end
    
    
    # Detect if NLM has removed/renamed any MeSH Headings since our last update
    missing_mesh_ids = MeshKeywordLookup::DESCRIPTORS.values - keyword_lookup.values
    
    if missing_mesh_ids.length > 0
      # We know we'll need to remove the offenders from Redis
      puts "Detected removed/renamed MeSH IDs: #{missing_mesh_ids.join(', ')}"
    end
    
    
    # Write the results of this parse out to the appropriate files in /lib
    @today = Time.now.strftime("%d %B %Y")
    
    File.open( File.join(RAILS_ROOT, 'lib', 'mesh_keyword_lookup.rb'), 'w') do |f|
      output = ERB.new(mesh_keyword_lookup_template)
      descriptor_hash_string =  keyword_lookup.map{|name, id| %("#{name}" => #{id})}.join(",\n")
      f.puts output.result(binding)
    end
    
    File.open( File.join(RAILS_ROOT, 'lib', 'mesh_score_lookup.rb'), 'w') do |f|
      output = ERB.new(mesh_score_lookup_template)
      score_hash_string =  count_lookup.map{|id, count| %(#{id} => #{count})}.join(",\n")
      f.puts output.result(binding)
    end
    
    # Reload the MeshKeyword table given the new data
    Rake::Task['mesh:seed_database'].invoke
  end
end


def mesh_keyword_lookup_template
  <<-END_TEMPLATE
  # This module serves as a lookup table for MeSH Terms, last updated <%= @today %>
  #
  # DO NOT EDIT, this file is generated by `rake mesh:create_indexes`
  # See RAILS_ROOT/lib/tasks/mesh.rake for more information
  #
  # Using MeshKeywordLookup.[], you can look up the MeSH ID
  # for any MeSH Heading. Since there are not very many MeSH
  # terms, it's faster to hold these in memory than to hit the DB
  #
  # MeSH lookups are NOT case sensitive.
  #
  # === Example
  # MeshKeywordLookup['aging']
  # => 375

  module MeshKeywordLookup
    def self.[](mesh_descriptor_name)
      DESCRIPTORS[mesh_descriptor_name.to_s.upcase]
    end
    
    def self.each(&block)
      DESCRIPTORS.each do |descriptor, id|
        yield(descriptor, id)
      end
    end
  
    def self.length
      DESCRIPTORS.length
    end
  
    def self.updated_at
      return "<%= @today %>"
    end
  
    DESCRIPTORS={
      <%= descriptor_hash_string %>
    }
  end
  END_TEMPLATE
end

def mesh_score_lookup_template
  <<-END_TEMPLATE
  # This module serves as a lookup table for the downweighting score
  # of particular MeSH Terms, last updated <%= @today %>
  #
  # DO NOT EDIT, this file is generated by `rake mesh:create_indexes`
  # See RAILS_ROOT/lib/tasks/mesh.rake for more information
  #
  # Using MeshScoreLookup.[], you can look up the downweighting score
  # for any MeSH ID. Since there are not very many MeSH
  # terms, it's faster to hold these in memory than to hit the DB
  #
  # The score is computed by counting each MeSH term's frequency
  # across all of Medline. Each term's frequency is divided by
  # the largest frequency (the most frequenly applied MeSH term
  # in Medline) to arrive at a score ranging from 0.0 to 1.0.
  #
  # At the time of this writing, "Humans" was the most occurrent
  # term in Medline, and thus its score is 1.0. The terms
  # "Male" and "Female" were close, but not as prevalent.
  #
  # === Example
  # MeshScoreLookup[6801] # "Humans"
  # => 1.0
  
  module MeshScoreLookup
    def self.[](mesh_id)
      SCORES[mesh_id.to_i]
    end
    
    def self.each(&block)
      SCORES.each do |id, score|
        yield(id, score)
      end
    end
  
    def self.length
      SCORES.length
    end
  
    def self.updated_at
      return "<%= @today %>"
    end
    
    SCORES = {
      <%= score_hash_string %>
    }
  end
  END_TEMPLATE
end