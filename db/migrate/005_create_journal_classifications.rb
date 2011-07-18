class CreateJournalClassifications < ActiveRecord::Migration
  def self.up
    create_table :journal_classifications do |t|
      t.integer :journal_id, :journal_keyword_id
      t.timestamps
    end
    add_index :journal_classifications, :journal_id
    add_index :journal_classifications, :journal_keyword_id
  end

  def self.down
    remove_index :journal_classifications, :journal_id
    remove_index :journal_classifications, :journal_keyword_id
    drop_table :journal_classifications
  end
end
