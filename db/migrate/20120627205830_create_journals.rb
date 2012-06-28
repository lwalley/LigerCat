class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.text :title
      t.string :nlm_id
      t.string :title_abbreviation
      t.string :issn
      t.boolean :new_journal

      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
