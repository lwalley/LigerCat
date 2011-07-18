class CreateJournalMeshFrequencies < ActiveRecord::Migration
  def self.up
    create_table :journal_mesh_frequencies do |t|
      t.integer :journal_id, :mesh_id, :frequency
      t.timestamps
    end
    add_index :journal_mesh_frequencies, :journal_id
    add_index :journal_mesh_frequencies, :mesh_id
  end

  def self.down
    remove_index :journal_mesh_frequencies, :journal_id
    remove_index :journal_mesh_frequencies, :mesh_id
    drop_table :journal_mesh_frequencies
  end
end
