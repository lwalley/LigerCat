require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# Warning! This spec relies entirely on fixture data,
# and the spec will break if the fixtures go out of whack.

describe 'HistogramProcessor' do
  before(:each) do
    redis_fixture :date_published
    
    
    # This faked was snagged from the actual pubmed efetch. It contains medline records for the three @non_local_pmids
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:post, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi",
                         :body => RAILS_ROOT + "/spec/mocked_eutils_responses/histogram_processor_spec_efetch.xml")
                         
    # These PMIDs exist in the database, courtesy of the fixture above
    @local_pmids     = [3029810, 3029811, 3029812, 3029813, 3029814, 3029815, 3029816, 3029817, 3029818, 3029819, 3029820, 3029821] 
    @non_local_pmids = [3029822, 3029823, 3029824] # These will have to be looked up from PubMed
    
    @processor = LigerEngine::ProcessingStrategies::HistogramProcessor.new 
  end
  it "should build a histogram given a list of PMIDs" do
    results = @processor.process(@local_pmids + @non_local_pmids)
    
    results.should == {1985 => 7,
                       1986 => 6,
                       1987 => 2 }
  end
  
  it "should insert PMIDs retrived from PubMed into the database" do
    # Database Santiy Check.
    @non_local_pmids.each do |pmid|
      RedisFactory.gimme(:date_published).get(pmid).should be_nil, "Found the 'non-local' PMID #{pmid} in the database, when it shouldn't have been there."
    end
    
    @processor.process(@non_local_pmids)
    
    @non_local_pmids.each do |pmid|
      date_published = RedisFactory.gimme(:date_published).get(pmid)
      date_published.should_not be_nil, "PMID #{pmid} was expected to be in the database but was not"
      Date.parse(date_published).year.should be_between(1986, 1987) # all three @non_local_pmids were published between 1986 and 1987
    end
  end
end

def be_between(n1, n2)
  bounds = [n1,n2].sort
  simple_matcher("between"){|given| given >= bounds.first and given <= bounds.last }
end

