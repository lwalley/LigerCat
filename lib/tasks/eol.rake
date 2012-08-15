require 'fileutils'
require 'downloader'
require 'progressbar'
require 'dwc-archive'
require 'jazz_hands'

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
    
    
    dwc = DarwinCore.new(archive_filename)
    
    fields = dwc.core.fields
    
    taxon_id_index = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/taxonID'         }[:index]
    rank_index     = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/taxonRank'       }[:index]
    genus_index    = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/genus'           }[:index]
    species_index  = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/specificEpithet' }[:index]
    
    # Erase the existing EOL mapping
    EolTaxonConcept.delete_all
    
    # read content using a block with getting back results in sets 100 rows each
    dwc.core.read(10) do |data, errors|
      data.each do |d|
        taxon_id = d[taxon_id_index]
        rank     = d[rank_index]
        genus    = d[genus_index]
        species  = d[species_index]
        
        if rank == 'species'
          canonical_name = "#{genus} #{species}"
          query = BinomialQuery.find_or_create_by_query(cannonical_name)
          query.eol_taxon_concept.create(:id => taxon_id)
          query.save!
        end      
      end
    end
    
  end
end