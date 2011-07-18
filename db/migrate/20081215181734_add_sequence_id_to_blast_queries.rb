class AddSequenceIdToBlastQueries < ActiveRecord::Migration
  def self.up
    add_column :blast_queries, :sequence_id, :integer
    add_index :blast_queries, :sequence_id
  end

  def self.down
    remove_index :blast_queries, :sequence_id
    remove_column :blast_queries, :sequence_id
  end
end
