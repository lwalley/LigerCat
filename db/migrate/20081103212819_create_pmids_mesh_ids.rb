class CreatePmidsMeshIds < ActiveRecord::Migration
  def self.up
    create_table :pmids_mesh_ids, :id => false do |t|
      t.integer :pmid
      t.integer :mesh_keyword_id
    end
  end

  def self.down
    drop_table :pmids_mesh_ids
  end
end
