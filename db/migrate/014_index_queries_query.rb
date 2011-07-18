class IndexQueriesQuery < ActiveRecord::Migration
  def self.up
    add_index :queries, :query
  end

  def self.down
    remove_index :queries, :query
  end
end
