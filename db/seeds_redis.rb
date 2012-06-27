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

puts "Redis date_published database"

date_published_redis = RedisFactory.gimme('date_published')
date_published_url = 'http://dl.dropbox.com/u/635519/date_published_head.csv.gz'

begin
  downloader = FileDownloader.new(date_published_url)
  date_published_filename = downloader.filename
  
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
    
    
    seeding_progress = nil #put seeding_progress into scope
    
    gz.each_line do |line|
      if line[0,1] == '#'
        if line =~ /count:.*?(\d+)/
          seeding_progress = ProgressBar.new("Seeding", $1.to_i)
        end
      else
        seeding_progress.inc rescue nil
        
        pubmed_id, date_published = line.strip.split(',')
        pubmed_id = pubmed_id.to_i
      
        # date_published_redis.set(pubmed_id, date_published)
      end
    end
    
    seeding_progress.finish rescue nil
  ensure
    gz.close
  end
end

File.delete date_published_filename
