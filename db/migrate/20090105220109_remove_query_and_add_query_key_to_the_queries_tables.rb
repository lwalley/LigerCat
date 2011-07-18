class RemoveQueryAndAddQueryKeyToTheQueriesTables < ActiveRecord::Migration
  def self.up
    remove_index :blast_queries,   :query
    remove_index :journal_queries, :query
    remove_index :pubmed_queries,  :query
    
    remove_column :blast_queries,   :gi_number
    remove_column :journal_queries, :query
    remove_column :pubmed_queries,  :query
    
    add_column :pubmed_queries,  :query, :text
    add_column :journal_queries, :query, :text
    
    add_column :blast_queries,   :query_key, :string, :limit => 40
    add_column :journal_queries, :query_key, :string, :limit => 40
    add_column :pubmed_queries,  :query_key, :string, :limit => 40
    
    add_index :blast_queries,   :query_key
    add_index :journal_queries, :query_key
    add_index :pubmed_queries,  :query_key
  end

  def self.down
    remove_index :blast_queries,   :query_key
    remove_index :journal_queries, :query_key
    remove_index :pubmed_queries,  :query_key
    
    remove_column :blast_queries,   :query_key
    remove_column :journal_queries, :query_key
    remove_column :pubmed_queries,  :query_key
    
    remove_column :pubmed_queries, :query
    remove_column :journal_queries, :query
    
    add_column :blast_queries,   :gi_number, :string
    add_column :journal_queries, :query, :string
    add_column :pubmed_queries,  :query, :string
    
    add_index :blast_queries,   :gi_number
    add_index :journal_queries, :query
    add_index :pubmed_queries,  :query
  end
end
