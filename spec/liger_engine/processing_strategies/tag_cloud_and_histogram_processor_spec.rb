require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'TagCloudAndHistogramProcessor' do
  before(:each) do
    @processor = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    # These came back from an ESearch for "Biodiversity Informatics" and are in the redis fixtures below
    @pmids = [11009408, 12376687, 15063059, 15192219, 15253354, 16680511, 16956323, 17594421, 17704120, 18335319, 18445641, 19129210, 19473217, 19593896, 19729639, 19762632]
    
    redis_fixture :mesh
    redis_fixture :date_published
  end
  
  describe '#search' do
    it "should generate a tag cloud and a histogram" do
      results = @processor.process(@pmids)
      
      results.tag_cloud.should be_a Array
      results.histogram.should be_a Hash
      
      # Check the first entry of the tag cloud for sanity
      results.tag_cloud.first.should be_a Hash
      results.tag_cloud.first.should have_key :mesh_keyword_id
      results.tag_cloud.first.should have_key :frequency
      results.tag_cloud.first.should have_key :e_value
      
      # Check a couple values of the histogram for sanity
      # This will fail if the fixture data changes
      results.histogram[2007].should == 3
      results.histogram[2008].should == 2
      results.histogram[2009].should == 5
    end
  end
end
