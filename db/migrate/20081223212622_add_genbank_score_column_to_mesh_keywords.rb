class AddGenbankScoreColumnToMeshKeywords < ActiveRecord::Migration
  def self.up
    add_column :mesh_keywords, :genbank_score, :float
  end

  def self.down
    remove_column :mesh_keywords, :genbank_score
  end
end
