class RenameQueriesToJournalQueries < ActiveRecord::Migration
  def self.up
    drop_table :queries
    
    create_table :journal_queries do |t|
      t.string   :query
      t.integer  :max_mesh_score
      t.integer  :max_text_score
      t.timestamps
    end
    
    add_index :journal_queries, :query
  end

  def self.down
    drop_table :journal_queries
    
    create_table :queries, :force => true do |t|
      t.string   :query
      t.integer  :max_mesh_score
      t.integer  :max_text_score
      t.timestamps
    end
  end
end
