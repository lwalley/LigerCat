require 'spec_helper'

describe LigerEngine::PubmedFetcher do
  it "should accept a list of PMIDs and yield that many Bio::MEDLINEs" do
    pmids = [18784790, 18483570, 18445641, 18335319, 17704120, 17597923, 17594421, 16956323, 16701313, 16680511, 15253354, 15192219, 15063059, 12376687, 11009408]
    results = []
    
    LigerEngine::PubmedFetcher.fetch(pmids){|result| results << result}
    
    results.length.should == pmids.length
    results.all?{|r| r.is_a? Bio::MEDLINE }.should be_true
    results.map{|r| r.pmid.to_i }.should only_include(*pmids)
  end
end
