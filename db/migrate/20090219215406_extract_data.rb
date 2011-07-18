class ExtractData < DataInstallationHelper::TableDataMigration
	
  def self.up
		puts "Extracting LigerCat's indeces"
		in_data_directory do
			`tar -xvf #{datafile}`
		end
  end

  def self.down
		in_data_directory do 
			FileUtils.rm Dir.glob('*.csv*')
		end
  end
end
