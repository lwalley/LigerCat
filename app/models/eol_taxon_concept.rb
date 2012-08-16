class EolTaxonConcept < ActiveRecord::Base
  belongs_to :query
    
  attr_accessible :query_id, :id
  
  scope :with_articles, select('eol_taxon_concepts.id').joins(:query).where('queries.num_articles > 0')
  
end
