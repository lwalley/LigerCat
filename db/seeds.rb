# TODO call mesh:seed during this process
require 'active_record/fixtures'
require 'zlib'
require 'progressbar'
require 'fastercsv'
require 'downloader'

# Seed MeSH Table from local indexes
puts ""
Rake::Task['mesh:seed'].invoke


# Seed fact tables below

connection = ActiveRecord::Base.connection
url_base   = SEED_BASE_URL
dir        = File.join(Rails.root, 'tmp', 'seed_downloads')

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
  FCSV(gz, :encoding => 'u') do |csv|
      
    comment = csv.shift.first
      
    if comment =~ /count:.*?(\d+)/
      count = $1.to_i
    end
      
    if model.count == count
      puts "Table already has full set of #{count} rows, no need to seed"
    else 
      
      connection.execute "truncate #{model.table_name}"
      seeding_progress = ProgressBar.new("Seeding", count)
      
      header = csv.shift
      csv.each do |row|
        seeding_progress.inc
                    
        data = {}      
        row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.to_s.strip }
        
        # fill in timestamp columns if they aren't specified and the model is set to record_timestamps
        if model.record_timestamps
          %w(created_at updated_at).each do |name|
            data[name] = now unless data.key?(name)
          end
        end
        
        f = Fixture.new(data, model, connection)
        
        connection.insert_fixture(f, model.table_name)
      end
      
      seeding_progress.finish
        
    end
  end
    
  gz.close
end
  
File.delete(filename_with_path)

