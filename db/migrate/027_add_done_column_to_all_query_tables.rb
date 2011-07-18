class AddDoneColumnToAllQueryTables < ActiveRecord::Migration
  def self.up
    
    remove_column :blast_queries, :blasted
    
    add_column :blast_queries,   :done, :boolean, :default => false
    add_column :journal_queries, :done, :boolean, :default => false
    add_column :nuccore_queries, :done, :boolean, :default => false
  end

  def self.down
    remove_column :blast_queries, :done
    remove_column :journal_queries, :done
    remove_column :nuccore_queries, :done
    
    add_column :blast_queries, :blasted, :boolean, :default => false
  end
end
