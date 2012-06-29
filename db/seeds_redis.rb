# TODO seed date_published database
# TODO seed mesh database, possibly

require 'redis'
require 'downloader'
require 'progressbar'



#
#
# Download and seed the date_published Redis db
#
#

puts "\ndate_published"

redis = RedisFactory.gimme('date_published')
redis.info # attempt to connect to redis before doing anything else

url = 'http://localhost/~rschenk/ligerseed/date_published_head.csv.gz'

begin
  downloader = FileDownloader.new(url, File.join(Rails.root, 'tmp', 'seed_downloads'))
  date_published_filename = downloader.path_to_file
  
  unless File.exists? date_published_filename
    download_progress = ProgressBar.new("Downloading", 100)
    
    downloader.download do |percent_complete|
      download_progress.set(100 * percent_complete)  
    end
    download_progress.finish
  end
rescue Exception => e
  File.delete date_published_file
  raise e
end


File.open date_published_filename do |f|
  begin
    gz = Zlib::GzipReader.new(f)
    
    comment = gz.readline
    header  = gz.readline
      
    if comment =~ /count:.*?(\d+)/
      seeding_progress = ProgressBar.new("Seeding", $1.to_i)
    end
    
    
    gz.each_line do |line|
      seeding_progress.inc rescue nil
        
      pubmed_id, date_published = line.strip.split(',')
      pubmed_id = pubmed_id.to_i
      
      redis.set(pubmed_id, date_published)
    end
    
    seeding_progress.finish rescue nil
  ensure
    gz.close
  end
end

File.delete date_published_filename
