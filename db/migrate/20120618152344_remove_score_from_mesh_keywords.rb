class RemoveScoreFromMeshKeywords < ActiveRecord::Migration
  def self.up
    change_table :mesh_keywords do |t|
      t.remove :score
      t.remove :genbank_score
    end
    
  end

  def self.down
    change_table :mesh_keywords do |t|
      t.float :score
      t.float :genbank_score
    end
    
  end
end
