class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.text :title
      t.string :nlm_id, :title_abbreviation, :issn
      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
