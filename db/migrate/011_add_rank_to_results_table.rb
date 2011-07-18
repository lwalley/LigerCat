class AddRankToResultsTable < ActiveRecord::Migration
  def self.up
    add_column :results, :rank, :float
  end

  def self.down
    remove_column :results, :rank
  end
end
