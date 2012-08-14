# This class is used by BinomialPubmedSearchStrategy to map gi numbers into PMIDS
#
# TODO: Put this into Redis!!
class PmidGenbank < ActiveRecord::Base
  self.table_name = 'gi_numbers_pmids'
  self.record_timestamps = false
  
	class << self
		def find_all_by_gi_number(gi_number)
			super(gi_number, :select => 'pmid')
		end
	end
  
end