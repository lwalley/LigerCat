class DownloadData < DataInstallationHelper::TableDataMigration
	
  def self.up	
    require File.join(RAILS_ROOT, 'lib', 'downloader')
		
		FileUtils.mkdir_p data_directory
		
		in_data_directory do
			FileUtils.rm datafile, :force => true
		
			puts "Downloading LigerCat's indeces (550mB)"
			pbar = ProgressBar.new('Downloading', 100)
			dl = FileDownloader.new(url)
		
			dl.download{|percent_complete| pbar.set( (percent_complete * 100).to_i ) }
		
			pbar.finish
		end
  end

  def self.down
		FileUtils.rm_rf data_directory
  end
end
