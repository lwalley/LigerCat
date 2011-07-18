class AddEValueToBlastMeshFreqs < ActiveRecord::Migration
  def self.up
    add_column :blast_mesh_frequencies, :e_value, :float
  end

  def self.down
    remove_column :blast_mesh_frequencies, :e_value
  end
end
