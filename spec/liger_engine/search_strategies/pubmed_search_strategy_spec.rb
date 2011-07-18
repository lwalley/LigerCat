require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/search_strategy_spec')

describe LigerEngine::SearchStrategies::PubmedSearchStrategy do
  it_should_behave_like 'A Search Strategy'
  
  before(:each) do
    @strategy = LigerEngine::SearchStrategies::PubmedSearchStrategy.new
    @query = 'Sarkar IN'
  end
  
  describe '#search' do
    it "should return the correct PMIDs for a given query" do
      fake_esearch_response(query = 'biodiversity_informatics')
      results = @strategy.search(query)
    
      results.should only_include(18784790, 18483570, 18445641, 18335319, 17704120, 17597923, 17594421, 16956323, 16701313, 16680511, 15253354, 15192219, 15063059, 12376687, 11009408)
    end
  
    it "should raise an Exception if it can't reach PubMed"
    
    it "should load all PMIDs, even if retmax is set low" do
      results = @strategy.search('aging') # Over 200,000 results
      
      results.length.should > 200000
    end
  end
end