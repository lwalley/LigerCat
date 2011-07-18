class AddEValueToPubmedMeshFreqs < ActiveRecord::Migration
  def self.up
    add_column :pubmed_mesh_frequencies, :e_value, :float
  end

  def self.down
    remove_column :pubmed_mesh_frequencies, :e_value
  end
end
