# TODO call mesh:seed during this process
require 'active_record/fixtures'
require 'zlib'
require 'progressbar'
require 'downloader'

include ActionView::Helpers::NumberHelper

# Seed MeSH Table from local indexes
puts ""
Rake::Task['mesh:seed'].invoke


# Seed fact tables below

connection = ActiveRecord::Base.connection
url_base   = Ligercat::Application.config.seed_base_url
dir        = File.join(Rails.root, 'tmp', 'seed_downloads')
batch_size = 10000

model = PmidGenbank
puts "",
     model.table_name
  
now = Time.now.to_s(:db) 
filename = "#{model.table_name}.csv.gz"
filename_with_path = File.join(dir, filename)
url = url_base + filename
  
# Download GZipped seed file
  
begin
  downloader = FileDownloader.new(url, dir)
  
  if File.exists? filename_with_path
    puts "File #{filename} exists locally, skipping download"
  else
    download_progress = ProgressBar.new("Downloading", 100)
    
    downloader.download do |percent_complete|
      download_progress.set(100 * percent_complete)  
    end
    download_progress.finish
  end
rescue Exception => e
  File.delete filename_with_path if File.exists? filename_with_path
  raise e
end
    
File.open(filename_with_path) do |f|
  gz = Zlib::GzipReader.new(f)
  CSV(gz) do |csv|
      
    comment = csv.shift.first
      
    if comment =~ /count:.*?(\d+)/
      count = $1.to_i
    end
      
    if model.count == count
      puts "Table already has full set of #{count} rows, no need to seed"
    else 
      
      connection.execute "truncate #{model.table_name}"
      puts "Seeding #{number_with_delimiter count} records into #{model.table_name}"
      seeding_progress = ProgressBar.new("Seeding", count)
      
      header = csv.shift
      
      inserts = []
      
      columns = header.clone
      columns += %w(created_at updated_at) if model.record_timestamps
      column_names = columns.map{|k| "`#{k}`" }.join(', ')
      
      i = 0
      csv.each do |row|
        i += 1
        seeding_progress.inc
                    
        attributes = {}      
        row.each_with_index { |cell, j| attributes[header[j].to_s.strip] = cell.to_s.strip }
        
        # fill in timestamp columns if they aren't specified and the model is set to record_timestamps
        if model.record_timestamps
          %w(created_at updated_at).each do |name|
            attributes[name] = now unless attributes.key?(name)
          end
        end
        
                
        inserts << "(#{attributes.values.join(',')})"
        
        if i % batch_size == 0        
          connection.execute %(INSERT INTO `#{model.table_name}` (#{column_names}) VALUES #{inserts.join(", ")})
          inserts = []
        end
      end
      
      connection.execute %(INSERT INTO `#{model.table_name}` (#{column_names}) VALUES #{inserts.join(", ")})
      
      seeding_progress.finish
        
    end
  end
    
  gz.close
end
  
File.delete(filename_with_path)

