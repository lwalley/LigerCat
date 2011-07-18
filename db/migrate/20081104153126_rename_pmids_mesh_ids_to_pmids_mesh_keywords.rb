class RenamePmidsMeshIdsToPmidsMeshKeywords < ActiveRecord::Migration
  def self.up
    rename_table :pmids_mesh_ids, :pmids_mesh_keywords
  end

  def self.down
    rename_table :pmids_mesh_keywords, :pmids_mesh_ids
  end
end
