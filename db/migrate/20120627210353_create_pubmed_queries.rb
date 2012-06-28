class CreatePubmedQueries < ActiveRecord::Migration
  def self.up
    create_table :pubmed_queries do |t|
      t.text :query
      t.string :query_key
      t.boolean :state
      t.integer :num_articles
      t.string :full_species_name
      t.integer :eol_taxa_id

      t.timestamps
    end
    
    add_index :pubmed_queries, :query_key
    add_index :pubmed_queries, :eol_taxa_id
    add_index :pubmed_queries, :updated_at
  end

  def self.down
    drop_table :pubmed_queries
  end
end
