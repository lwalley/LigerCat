class CreateGiNumbersPmids < ActiveRecord::Migration
  def self.up
    create_table :gi_numbers_pmids do |t|
      t.integer :gi_number
      t.integer :pmid
    end
    
    add_index :gi_numbers_pmids, :gi_number
    add_index :gi_numbers_pmids, :pmid    
  end

  def self.down
    drop_table :gi_numbers_pmids
  end
end
