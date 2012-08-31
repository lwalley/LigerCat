require 'fileutils'
require 'downloader'
require 'progressbar'
require 'dwc-archive'
require 'zlib'
require 'digest/md5'
require 'open-uri'

require 'jazz_hands' if Rails.env.development?

namespace :eol do 
  desc "Downloads a DwC-Archive of EoL taxa to update the EoL PubmedQueries with newest taxa"
  task :import_archive => [:environment] do |t, args|
              
    
    # Read the MD5 digest of the archive, to see if we need to do anything
    begin
      md5 = URI.parse(Ligercat::Application.config.eol_archive_digest_url).read.strip
    rescue Exception => e
      abort "Could not load EoL Archive Digest from #{Ligercat::Application.config.eol_archive_digest_url} : #{e.message}"
    end
    
    if last_import = EolImport.find_by_checksum(md5)
      puts "Already imported #{last_import.checksum} on #{last_import.created_at}, skipping"
    else
      dir = File.join(Rails.root, 'tmp')
      archive_filename = ''
  
      # Download GZipped seed file
  
      begin
        downloader = FileDownloader.new(Ligercat::Application.config.eol_archive_file_url, dir)
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
        puts "Could not load EoL Archive  from #{Ligercat::Application.config.eol_archive_file_url} : #{e.message}"

        raise e
      end
    
      begin
        dwc = DarwinCore.new(archive_filename)
    
        fields = dwc.core.fields
    
        taxon_id_index = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/taxonID'         }[:index]
        rank_index     = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/taxonRank'       }[:index]
        genus_index    = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/genus'           }[:index]
        species_index  = fields.find{|f| f[:term] == 'http://rs.tdwg.org/dwc/terms/specificEpithet' }[:index]
    
        # Erase the existing EOL mapping
        EolTaxonConcept.delete_all
    
        # read content using a block with getting back results in sets 100 rows each
        dwc.core.read(100) do |data, errors|
          data.each do |d|
            taxon_id = d[taxon_id_index]
            rank     = d[rank_index]
            genus    = d[genus_index]
            species  = d[species_index]
            # status   = d[status_index]
        
            if rank == 'species' && !genus.blank? && !species.blank?
              puts canonical_name = "#{genus} #{species}"
              query = BinomialQuery.find_or_create_by_query(canonical_name)
              query.eol_taxon_concepts.build(:id => taxon_id)
              query.save!
            end      
          end
        end
        
        EolImport.create(:checksum => md5)
      ensure
        File.delete(archive_filename) if File.exists? archive_filename
      end

    end
  end
  
  
  # TODO Figure out how we're going to do any symlinking with Capistrano, so that this file can survive between deployments
  desc "Writes a list of all EoL taxa that we've got tag clouds for"
  task :write_list => [:environment] do
    filename = Rails.root.join('public', 'eol_ids_with_articles.txt')
    
    File.open( filename, 'w' ) do |f|    
      pbar = ProgressBar.new("Writing", EolTaxonConcept.with_articles.count)
      EolTaxonConcept.with_articles.find_each do |taxon_concept|
        pbar.inc
        f.puts taxon_concept.id
      end
      pbar.finish
    end
    
    puts "Checksumming..."
    File.open(filename.to_s.gsub(filename.extname, '.md5'), 'w') do |f|
      f.write Digest::MD5.file( filename )
    end
    
    puts "Compressing..."
    `gzip -9f #{filename}`
  end
end