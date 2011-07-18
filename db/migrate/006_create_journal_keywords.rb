class CreateJournalKeywords < ActiveRecord::Migration
  def self.up
    create_table :journal_keywords do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :journal_keywords
  end
end
