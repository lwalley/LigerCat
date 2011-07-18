
# NOTE!! ID == GI
# A sequence's id/primary key attribute is its GI number!
#
# I didn't feel that it was worth the effort to add a second column for the GI, or 
# break a bunch of Rails conventions by dropping the 'id' attribute from the sequences
# table in favor of a column called 'gi'. So please keep that in mind

class CreateSequences < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.string :accession_number
      t.timestamps
    end
    
    add_index :sequences, :accession_number
  end

  def self.down
    drop_table :sequences
  end
end
