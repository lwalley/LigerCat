class BlastResult < ActiveRecord::Base
  belongs_to :sequence
  belongs_to :blast_query
end
