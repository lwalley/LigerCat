class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.string :type
      t.integer :state
      t.string :key
      t.text :query
      t.integer :num_articles

      t.timestamps
    end
    
    add_index :queries, :type
    add_index :queries, :key
    add_index :queries, :updated_at
  end

  def self.down
    drop_table :queries
  end
end
