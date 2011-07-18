class RenameResultsToJournalResults < ActiveRecord::Migration
  def self.up
    drop_table :results
    
    create_table :journal_results do |t|
      t.integer :journal_id
      t.integer :journal_query_id
      t.float   :search_term_score
      t.integer :mesh_score
      t.integer :text_score
      t.timestamps
    end
    
    add_index :journal_results, :journal_id
    add_index :journal_results, :journal_query_id
  end

  def self.down
    drop_table :journal_results
    
    create_table :results, :force => true do |t|
      t.integer  :journal_id
      t.integer  :query_id
      t.float    :search_term_score
      t.integer  :mesh_score
      t.integer  :text_score
      t.timestamps
    end
    
    add_index :results, :journal_id
    add_index :results, :query_id
  end
end
