class CreateMeshFrequencies < ActiveRecord::Migration
  def self.up
    create_table :mesh_frequencies do |t|
      t.integer :query_id
      t.integer :mesh_keyword_id
      t.integer :frequency
      t.integer :weighted_frequency

      t.timestamps
    end
    
    add_index :mesh_frequencies, :query_id
    add_index :mesh_frequencies, :mesh_keyword_id
  end

  def self.down
    drop_table :mesh_frequencies
  end
end
