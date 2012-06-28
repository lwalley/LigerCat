class CreateJournalTextFrequencies < ActiveRecord::Migration
  def self.up
    create_table :journal_text_frequencies do |t|
      t.integer :journal_id
      t.integer :text_keyword_id
      t.integer :frequency

      t.timestamps
    end
    
    add_index :journal_text_frequencies, :journal_id
    add_index :journal_text_frequencies, :text_keyword_id
  end

  def self.down
    drop_table :journal_text_frequencies
  end
end
