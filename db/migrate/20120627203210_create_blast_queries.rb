class CreateBlastQueries < ActiveRecord::Migration
  def self.up
    create_table :blast_queries do |t|
      t.boolean :state
      t.string :query_key

      t.timestamps
    end
    
    add_index :blast_queries, :query_key
    add_index :blast_queries, :updated_at
  end

  def self.down
    drop_table :blast_queries
  end
end
