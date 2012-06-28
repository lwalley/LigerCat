class CreateJournalMeshFrequencies < ActiveRecord::Migration
  def self.up
    create_table :journal_mesh_frequencies do |t|
      t.integer :journal_id
      t.integer :mesh_id
      t.integer :frequency

      t.timestamps
    end
    
    add_index :journal_mesh_frequencies, :journal_id
    add_index :journal_mesh_frequencies, :mesh_id
    
  end
  
  def self.down
    drop_table :journal_mesh_frequencies
  end
end
