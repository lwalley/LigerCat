class CleanupData < DataInstallationHelper::TableDataMigration
  def self.up
		FileUtils.rm_rf data_directory
  end

  def self.down
  end
end
