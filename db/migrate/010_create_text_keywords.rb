class CreateTextKeywords < ActiveRecord::Migration
  def self.up
    create_table :text_keywords do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :text_keywords
  end
end
