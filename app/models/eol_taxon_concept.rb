class EolTaxonConcept < ActiveRecord::Base
  belongs_to :query
  
  validates_presence_of :query_id
  
  attr_accessible :query_id, :id
end
