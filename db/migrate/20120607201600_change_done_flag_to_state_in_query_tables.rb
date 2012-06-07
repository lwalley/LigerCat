class ChangeDoneFlagToStateInQueryTables < ActiveRecord::Migration
  def self.up  
    [BlastQuery, PubmedQuery, JournalQuery].each do |model|
      
      model.delete_all("done = 0")
      
      rename_column(model.table_name, :done, :state)
      change_column(model.table_name, :state, :integer, :default => nil)
    end
  end

  def self.down
    [:blast_queries, :pubmed_queries, :journal_queries].each do |table_name|
      rename_column(table_name, :state, :done)
      change_column(table_name, :done, :boolean, :default => false)
    end
  end
end
