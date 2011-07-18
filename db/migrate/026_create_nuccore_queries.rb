class CreateNuccoreQueries < ActiveRecord::Migration
  def self.up
    create_table :nuccore_queries do |t|
      t.string :query
      t.timestamps
    end
    add_index :nuccore_queries, :query
  end

  def self.down
    drop_table :nuccore_queries
  end
end
