class AddMeshScore < ActiveRecord::Migration
  def self.up
    add_column :mesh_keywords, :score, :float
  end

  def self.down
    remove_column :mesh_keywords, :score
  end
end
