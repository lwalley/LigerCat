class CreateBlastResults < ActiveRecord::Migration
  def self.up
    create_table :blast_results do |t|
      t.integer :sequence_id
      t.integer :blast_query_id
      t.float :e_value

      t.timestamps
    end
    add_index :blast_results, :sequence_id
    add_index :blast_results, :blast_query_id
  end

  def self.down
    remove_index :blast_results, :sequence_id
    remove_index :blast_results, :blast_query_id

    drop_table :blast_results
  end
end
