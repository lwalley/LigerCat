class CreateJournalQueries < ActiveRecord::Migration
  def self.up
    create_table :journal_queries do |t|
      t.text :query
      t.string :query_key
      t.boolean :state
      t.integer :max_mesh_score
      t.integer :max_text_score

      t.timestamps
    end
    
    add_index :journal_queries, :query_key
  end

  def self.down
    drop_table :journal_queries
  end
end
