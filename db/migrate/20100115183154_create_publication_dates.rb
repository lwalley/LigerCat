class CreatePublicationDates < ActiveRecord::Migration
  def self.up
    create_table :publication_dates do |t|
      # Compound primary key for polymorphic associations
      # Note indexing nullable columns is slower, and the longer the varchar the slower the index
      t.integer :query_id,   :null => false
      t.string  :query_type, :null => false, :limit => 20
      
      t.integer :year
      t.integer :publication_count
    end
    add_index :publication_dates, [:query_type, :query_id]
  end

  def self.down
    drop_table :publication_dates
  end
end
 