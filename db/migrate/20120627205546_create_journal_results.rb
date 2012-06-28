class CreateJournalResults < ActiveRecord::Migration
  def self.up
    create_table :journal_results do |t|
      t.integer :journal_id
      t.integer :journal_query_id
      t.float :search_term_score
      t.integer :mesh_score
      t.integer :text_score

      t.timestamps
    end
    
    add_index :journal_results, :journal_id
    add_index :journal_results, :journal_query_id
  end

  def self.down
    drop_table :journal_results
  end
end
