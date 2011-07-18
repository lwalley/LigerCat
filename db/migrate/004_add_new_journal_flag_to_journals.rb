class AddNewJournalFlagToJournals < ActiveRecord::Migration
  def self.up
    add_column :journals, :new_journal, :boolean, :default => false
  end

  def self.down
    remove_column :journals, :new_journal
  end
end
