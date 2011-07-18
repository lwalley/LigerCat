class CreateGiNumbersPmids < ActiveRecord::Migration
  def self.up
	  # You: SQL? A CPK? Are you on drugs, Ryan?
	  #
	  # Ryan: I wish...
	  #
	  #       To get the MAXIMUM PERFORMANCE out of this lookup table while
	  #       maintaining the SMALLEST SIZE on the disc, Dima says it is most
	  #       efficient to specify a CPK instead of separate indeces.
	  # 
	  #       In order to that, I needed to jump down into SQL instead of 
	  #       using the migration DSL
    execute("CREATE TABLE gi_numbers_pmids(" +
    				"			gi_number int(11)," +
    				"			pmid int(11)," +
    				"			PRIMARY KEY(gi_number, pmid)"+
    				") ENGINE=InnoDB")
  end

  def self.down
    drop_table :gi_numbers_pmids
  end
end
