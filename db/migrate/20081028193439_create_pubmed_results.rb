class CreatePubmedResults < ActiveRecord::Migration
  def self.up
    create_table :pubmed_results do |t|
      t.integer :pubmed_query_id
      t.integer :pmid
      t.timestamps
    end
    
    add_index :pubmed_results, :pmid
    add_index :pubmed_results, :pubmed_query_id
  end

  def self.down
    drop_table :pubmed_results
  end
end
