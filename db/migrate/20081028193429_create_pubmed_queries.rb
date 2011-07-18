class CreatePubmedQueries < ActiveRecord::Migration
  def self.up
    create_table :pubmed_queries do |t|
      t.string :query
      t.boolean :done, :default => false
      t.timestamps
    end
    
    add_index :pubmed_queries, :query
  end

  def self.down
    drop_table   :pubmed_queries
  end
end
