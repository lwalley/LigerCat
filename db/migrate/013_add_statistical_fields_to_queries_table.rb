class AddStatisticalFieldsToQueriesTable < ActiveRecord::Migration
  def self.up
    add_column :queries, :max_mesh_score, :int
    add_column :queries, :max_text_score, :int
  end

  def self.down
    remove_column :queries, :max_mesh_score
    remove_column :queries, :max_text_score
  end
end
