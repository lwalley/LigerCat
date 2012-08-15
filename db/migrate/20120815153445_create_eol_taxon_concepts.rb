class CreateEolTaxonConcepts < ActiveRecord::Migration
  def change
    create_table :eol_taxon_concepts do |t|
      t.integer :query_id
      t.timestamps
    end
    
    add_index :eol_taxon_concepts, :query_id    
  end
end
