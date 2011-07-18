class RenameQueryToGiNumberInBlastQueriesTable < ActiveRecord::Migration
  def self.up
    rename_column :blast_queries, :query, :gi_number
  end

  def self.down
    rename_column :blast_queries, :gi_number, :query
  end
end
