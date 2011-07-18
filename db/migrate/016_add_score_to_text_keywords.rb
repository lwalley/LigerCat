class AddScoreToTextKeywords < ActiveRecord::Migration
  def self.up
    add_column :text_keywords, :score, :float
  end

  def self.down
    remove_column :text_keywords, :score
  end
end
