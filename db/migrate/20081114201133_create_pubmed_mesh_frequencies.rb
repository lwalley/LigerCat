class CreatePubmedMeshFrequencies < ActiveRecord::Migration
  def self.up
    create_table :pubmed_mesh_frequencies do |t|
      t.integer :pubmed_query_id
      t.integer :mesh_keyword_id
      t.integer :frequency
      t.timestamps
    end
    
    add_index :pubmed_mesh_frequencies, :pubmed_query_id
    add_index :pubmed_mesh_frequencies, :mesh_keyword_id
    add_index :pubmed_mesh_frequencies, [:pubmed_query_id, :mesh_keyword_id], :name => 'by_pubmed_query_id_and_mesh_keyword_id'
  end

  def self.down
    drop_table :pubmed_mesh_frequencies
  end
end
