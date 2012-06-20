class IndexStateAndUpdatedAtOnPubmedQueriesAndBlastQueries < ActiveRecord::Migration
  def self.up
    [:pubmed_queries, :blast_queries].each do |table_name|
      add_index table_name, :state
      add_index table_name, :updated_at
    end
  end

  def self.down
    [:pubmed_queries, :blast_queries].each do |table_name|
      remove_index table_name, :state
      remove_index table_name, :updated_at
    end
    
  end
end
