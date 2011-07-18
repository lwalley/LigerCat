class CreateBlastMeshFrequencies < ActiveRecord::Migration
  def self.up
    create_table :blast_mesh_frequencies do |t|
      t.integer :blast_query_id
      t.integer :mesh_keyword_id
      t.integer :frequency
      t.timestamps
    end
    
    add_index :blast_mesh_frequencies, :blast_query_id
    add_index :blast_mesh_frequencies, :mesh_keyword_id
    add_index :blast_mesh_frequencies, [:blast_query_id, :mesh_keyword_id], :name => 'by_blast_query_id_and_mesh_keyword_id'
  end

  def self.down
    drop_table :blast_mesh_frequencies
  end
end
