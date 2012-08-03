require 'spec_helper'
require 'liger_engine/search_strategies/search_strategy'

describe LigerEngine::SearchStrategies::EolPubmedSearchStrategy do
  it_should_behave_like 'A Search Strategy'
  
  before(:each) do
    @strategy = LigerEngine::SearchStrategies::EolPubmedSearchStrategy.new
    @query = 'Galaxias maculatus'
    
    FakeWeb.allow_net_connect = false
    fake_esearch_response(@strategy.class.species_specific_query(@query), :file => 'Galaxias_maculatus_esearch.xml')
  end
  
  describe '#search' do    
    it "should transform the given query into Holly's species one" do      
      special_pubmed_query = @strategy.class.species_specific_query(@query)
      
      FakeWeb.clean_registry
      fake_esearch_response(special_pubmed_query, :file => 'Galaxias_maculatus_esearch.xml')
      
      lambda{ @strategy.search(@query) }.should_not raise_error
    end
  end
  
  describe '#species_specific_query' do
    it "should transform a binomial into Holly's special Pubmed query" do
      query                  = 'Galaxias maculatus'
      special_pubmed_version = '"Galaxias maculatus"[tiab] OR "Galaxias maculatus"[MeSH Terms] OR ("G. maculatus"[tiab] AND Galaxias[tiab])'
      
      @strategy.class.species_specific_query(query).should == special_pubmed_version
    end
  end
end