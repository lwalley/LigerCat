class AddBlastQueryIdToSequences < ActiveRecord::Migration
  def self.up
    # I'm a dumbass and put the FK in the wrong table
    add_column :sequences, :blast_query_id, :integer
    add_index :sequences, :blast_query_id
    
    remove_index :blast_queries, :sequence_id
    remove_column :blast_queries, :sequence_id
  end

  def self.down
    remove_column :sequences, :blast_query_id
    remove_index :sequences, :blast_query_id
    
    add_column :blast_queries, :sequence_id, :integer
    add_index  :blast_queries, :sequence_id
  end
end
