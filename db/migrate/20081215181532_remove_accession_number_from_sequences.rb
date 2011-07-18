class RemoveAccessionNumberFromSequences < ActiveRecord::Migration
  def self.up
    remove_column :sequences, :accession_number
  end

  def self.down
    add_column :sequences, :accession_number, :string
  end
end
