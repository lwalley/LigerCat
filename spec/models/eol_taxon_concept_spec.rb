require 'spec_helper'

describe EolTaxonConcept do
  fixtures :eol_taxon_concepts, :queries
  
  it "should be possible to create one with an explicit id and query_id" do
    q = EolTaxonConcept.new(:id => 1234, :query_id => 5678)
    q.save!
  end
  
  it "should have a BinomialQuery" do
    eol_taxon_concepts(:a_taxon_concept).query.should be_a BinomialQuery
  end
end
