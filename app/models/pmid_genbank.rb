# This class is used by EoLPubmedSearchStrategy to map gi numbers into PMIDS
#
# TODO: Put this into Redis!!
class PmidGenbank < ActiveRecord::Base
  set_table_name 'gi_numbers_pmids'

	class << self
		def find_all_by_gi_number(gi_number)
			super(gi_number, :select => 'pmid')
		end
	end
  
end