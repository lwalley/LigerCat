class CreateNuccoreResults < ActiveRecord::Migration
  def self.up
    create_table :nuccore_results do |t|
      t.integer :sequence_id
      t.integer :nuccore_query_id
      t.timestamps
    end
    add_index :nuccore_results, :sequence_id
    add_index :nuccore_results, :nuccore_query_id
  end

  def self.down
    remove_index :nuccore_results, :sequence_id
    remove_index :nuccore_results, :nuccore_query_id

    drop_table :nuccore_results
  end
end
