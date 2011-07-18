class IndexPmidsMeshIds < ActiveRecord::Migration
  def self.up
    add_index :pmids_mesh_ids, [:pmid, :mesh_keyword_id]
  end

  def self.down
    remove_index :pmids_mesh_ids, [:pmid, :mesh_keyword_id]
  end
end
