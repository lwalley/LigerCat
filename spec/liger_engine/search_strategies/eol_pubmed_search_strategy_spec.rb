require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/search_strategy_spec')

describe LigerEngine::SearchStrategies::EolPubmedSearchStrategy do
  it_should_behave_like 'A Search Strategy'
  
  before(:each) do
    @strategy = LigerEngine::SearchStrategies::EolPubmedSearchStrategy.new
    @query = 'Galaxias maculatus'
  end
  
  describe '#search' do
    after(:each) do
      FakeWeb.clean_registry
      FakeWeb.allow_net_connect = true
    end
    
    it "should transform the given query into Holly's species one" do
      FakeWeb.allow_net_connect = false  # This will raise an Error and fail the spec if we don't hit the given URL below
      
      special_pubmed_query = @strategy.class.species_specific_query(@query)
      
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