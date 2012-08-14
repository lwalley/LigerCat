class CreateSequences < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.integer :query_id
      t.text :fasta_data

      t.timestamps
    end
    
    add_index :sequences, :query_id
  end

  def self.down
    drop_table :sequences
  end
end
