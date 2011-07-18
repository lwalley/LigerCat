class AddBlastedFieldToBlastQueries < ActiveRecord::Migration
  def self.up
    add_column :blast_queries, :blasted, :boolean, :default => false
  end

  def self.down
    remove_column :blast_queries, :blasted
  end
end
