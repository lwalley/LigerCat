namespace :import do
  desc "Imports a file of species names into the system. It expects one species name per line."
  task :species_file => :environment do
    if STDIN.tty?
      puts "USAGE:", 
           "rake import:species_file < list_of_species_names.txt\n",
           "",
           "The input file should contain one species name per line, like so:",
           "---------- Input File ----------",
           "Corvus brachyrhynchos\nGeochelone nigra\nMyxine glutinosa\nHomo sapiens\nUrsus maritimus\nSaccharomyces cerevisiae\nEOF"
    else
      STDIN.each_line do |line|
        PubmedQuery.create :query => line.strip
      end
    end
  end

  desc "Imports a tab delimited file of species names into the system. It expects one species name per line."
  task :eol_species_file => :environment do
    if STDIN.tty?
      puts "USAGE:", 
           "rake import:eol_species_file < list_of_species_names.txt\n",
           "",
           "The input file should tab delimited EOL taxa id, full species name, and the binomial name, like so:",
           "---------- Input File ----------",
           "114749\tGlaphyra shimai Hayashi & Makihara, 1981\tGlaphyra shimai\n114750\tStromatium barbatum (Fabricius, 1775)\tStromatium barbatum\n114751\tRhytidodera simulans (White, 1853)\tRhytidodera simulans\n114752\tHoplocerambyx spinicornis (Newman, 1842)\tHoplocerambyx spinicornis\n114753\tRhytidodera bowringi White, 1853\tRhytidodera bowringi\nEOF"
    else
      STDIN.each_line do |line|
        eol_taxa_id, full_species_name, binomial = line.strip.split("\t")
        PubmedQuery.create :query => binomial, :full_species_name => full_species_name, :eol_taxa_id => eol_taxa_id
      end
    end
  end
  
  desc "Imports a directory of files"
  task :eol_directory => :environment do
  begin
    require 'ftools'
    
    input_dir  = '/Users/rschenk/Desktop/EoL_Names/to_do'
    output_dir = '/Users/rschenk/Desktop/EoL_Names/finished'
    
    queue_threshold = 100
    
    if queue_size() < queue_threshold
      next_file_to_enqueue = Dir[input_dir + '/split_eol_names*'].first
      
      File.open(next_file_to_enqueue) do |f|
        f.each_line do |line|
          eol_taxa_id, full_species_name, binomial = line.strip.split("\t")
          PubmedQuery.create :query => binomial, :full_species_name => full_species_name, :eol_taxa_id => eol_taxa_id
        end
      end
      
      File.move(next_file_to_enqueue, output_dir)
    end
  rescue Exception => e
    logger.error "Import error #{e.to_s}"
  end
  end
end


def queue_size
  require 'bunny'
  Bunny.run(:host => '128.128.164.99') do |b|
    q = b.queue('pubmed_workers__execute_search')
    return q.status[:message_count]
  end
end
