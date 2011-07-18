class AddFastaDataToSequences < ActiveRecord::Migration
  def self.up
    add_column :sequences, :fasta_data, :text
  end

  def self.down
    remove_column :sequences, :fasta_data
  end
end
