class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.integer :journal_id, :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
