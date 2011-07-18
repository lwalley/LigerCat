module DataInstallationHelper
		
	class TableDataMigration < ActiveRecord::Migration
	
		class << self
			
			
			def url
				@url ||= 'http://nstage/ligercat_data/ligercat_data.tar'
			end
			
			def data_directory
				@data_directory ||=  File.join(RAILS_ROOT, 'db', 'data')
			end
			
			def datafile
				@datafile ||= url[%r{[^/]+\z}]
			end
			
			
			def in_data_directory(&block)			
				current_dir = Dir.pwd
				begin
					Dir.chdir data_directory
					yield block
				ensure
					Dir.chdir current_dir
				end
			end
			
			def table_name
				@table_name ||= self.name.gsub('Extract','').gsub('Load', '').gsub('Data','').tableize
			end
		end
	end
	
	class TableDataExtrationMigration < DataInstallationHelper::TableDataMigration		
		class << self
			def up
				in_data_directory do
					puts "Uncompressing #{table_name}.csv.gz"
					`gunzip #{table_name}.csv.gz`
				end
			end
		
			def down
			  in_data_directory do
					`gzip #{table_name}.csv` if File.exists("#{table_name}.csv")
				end
			end
		end
	end
	
	class TableDataLoaderMigration < DataInstallationHelper::TableDataMigration		
		class << self
			def up
				in_data_directory do
					puts "Loading #{table_name}.csv into #{table_name}"
					execute "LOAD DATA INFILE '#{Dir.pwd}/#{table_name}.csv' INTO TABLE #{table_name} " +
	                "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' " +
									"LINES TERMINATED BY '\\n' "+
									"IGNORE 1 LINES"
					FileUtils.rm_rf "#{table_name}.csv"
				end
			end
		
			def down
				execute "DELETE FROM #{table_name} WHERE 1"
			end
		end
	end
	
end