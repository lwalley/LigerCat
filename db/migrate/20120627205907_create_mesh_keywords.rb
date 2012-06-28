class CreateMeshKeywords < ActiveRecord::Migration
  def self.up
    create_table :mesh_keywords do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :mesh_keywords
  end
end
