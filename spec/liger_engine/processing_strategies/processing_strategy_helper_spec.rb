require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'bio'
require 'nokogiri'

describe 'ProcessingStrategyHelper' do
  before(:all) do
    class Implementation
      include LigerEngine::ProcessingStrategies::ProcessingStrategyHelper
      
      def each_pmid(id)
        if id > 16000000 # See @input below
          "yay!"
        end
      end
      
      def each_nonlocal(id)
        "woohoo"
      end
      
      def return_results
        "results"
      end
    end
  end
  
  before(:each) do
    @implementation = Implementation.new

    # Randomly selected PMIDs
    @input = [12376687, 15063059, 15192219, 15253354, 16680511, 16956323, 17594421, 18445641]
  end
  
  it "should call each_pmid with each input given" do
    @input.each do |i|
      @implementation.should_receive(:each_pmid).with(i).and_return(true)
    end
    
    @implementation.process(@input)
  end
  
  it "should retrieve nonlocal pmids from pubmed and call each_nonlocal with corresponding Nokogiri::XML::Element documents" do
    # Exactly 4 times, because each_pmid above checks for a PMID that is greater than 16000000.
    # Given @input, there are 4 pmids that are less than that number
    @implementation.should_receive(:each_nonlocal).exactly(4).times.with(an_instance_of(Nokogiri::XML::Element))
    
    @implementation.process(@input)
  end
  
  it "should return the results of return_results" do
    @implementation.process(@input).should == 'results'
  end
end