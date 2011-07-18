class CreateBlastQueries < ActiveRecord::Migration
  def self.up
    create_table :blast_queries do |t|
      t.string :query

      t.timestamps
    end
    
    add_index :blast_queries, :query
  end

  def self.down
    remove_index :blast_queries, :query
    drop_table :blast_queries
  end
end
