class CreateJournalTextFrequencies < ActiveRecord::Migration
  def self.up
    create_table :journal_text_frequencies do |t|
      t.integer :journal_id, :text_keyword_id, :frequency
      t.timestamps
    end
    add_index :journal_text_frequencies, :journal_id
    add_index :journal_text_frequencies, :text_keyword_id
  end

  def self.down
    remove_index :journal_text_frequencies, :journal_id
    remove_index :journal_text_frequencies, :text_keyword_id
    drop_table :journal_text_frequencies
  end
end
