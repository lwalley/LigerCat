require 'fileutils'
require 'downloader'
require 'progressbar'
require 'nokogiri'

namespace :eol do 
  desc "Downloads a DwC-Archive of EoL taxa to update the EoL PubmedQueries with newest taxa"
  task :create_queries, [:url_to_archive_tar_gz] => [:environment] do |t, args|
    
    abort "You must pass in the name of a file to load,\n"+
          " Example: rake eol:create_queries[http://eol.org/archive.tar.gz]" unless args.url_to_archive_tar_gz
          
    
    dir = File.join(Rails.root, 'tmp')
    archive_filename = ''
  
    # Download GZipped seed file
  
    begin
      downloader = FileDownloader.new(args.url_to_archive_tar_gz, dir)
      archive_filename = downloader.path_to_file
      
  
      if File.exists? archive_filename
        puts "File #{archive_filename} exists locally, skipping download"
      else
        download_progress = ProgressBar.new("Downloading", 100)
    
        downloader.download do |percent_complete|
          download_progress.set(100 * percent_complete)  
        end
        
        download_progress.finish
      end
    rescue Exception => e
      File.delete archive_filename if File.exists? archive_filename
      raise e
    end
    
    archive_dir = archive_filename.chomp('.tar.gz')
    FileUtils.mkdir_p archive_dir
    
    puts "\nExtracting"
    puts command = "tar -zxvf #{archive_filename} -C #{archive_dir}"
    `#{command}`
    
    metadata = Nokogiri::XML(open(File.join(archive_dir, 'meta.xml')))
    # binding.pry
    core = metadata.css('archive core').first # using .css here because xpath with namespaces is a major pain

    field_delimiter     = core['fieldsTerminatedBy']
    ignore_header_lines = core['ignoreHeaderLines']
    
    taxa_file = core.css('files location').first.content
    
    taxon_id_index  = core.css('field[term="http://rs.tdwg.org/dwc/terms/taxonID"]').first['index'].to_i
    full_name_index = core.css('field[term="http://rs.tdwg.org/dwc/terms/scientificName"]').first['index'].to_i
    genus_index     = core.css('field[term="http://rs.tdwg.org/dwc/terms/genus"]').first['index'].to_i
    #epithet_index   = core.css('field[term="http://rs.tdwg.org/dwc/terms/specificEpithet"]').first['index'].to_i
    rank_index      = core.css('field[term="http://rs.tdwg.org/dwc/terms/taxonRank"]').first['index'].to_i
    
    
    File.open( File.join(archive_dir, taxa_file) ) do |f|
      f.each_line do |line|
        next if f.lineno == 1 and ignore_header_lines == "1"
        
        columns = line.split(field_delimiter)
        
        taxon_id  = columns[taxon_id_index]
        full_name = columns[full_name_index]
        genus     = columns[genus_index]
        #epithet   = columns[epithet_index]
        rank      = columns[rank_index]
        
        
        # Check if rank is species
        # Check if taxon_id is already in database
        # barring that, insert new record
      end
    end
    
  end
end