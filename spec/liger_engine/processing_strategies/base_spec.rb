require 'spec_helper'
require 'liger_engine/processing_strategies/base'
require 'bio'
require 'nokogiri'

describe 'ProcessingStrategies::Base' do
  before(:all) do
    class Implementation < LigerEngine::ProcessingStrategies::Base
      
      def each_id(id)
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
  
  it "should call each_id with each input given" do
    @input.each do |i|
      @implementation.should_receive(:each_id).with(i).and_return(true)
    end
    
    @implementation.process(@input)
  end
  
  it "should retrieve nonlocal pmids from pubmed and call each_nonlocal with corresponding Nokogiri::XML::Element documents" do
    # Exactly 4 times, because each_id above checks for a PMID that is greater than 16000000.
    # Given @input, there are 4 pmids that are less than that number
    @implementation.should_receive(:each_nonlocal).exactly(4).times.with(an_instance_of(Nokogiri::XML::Element))
    
    @implementation.process(@input)
  end
  
  it "should return the results of return_results" do
    @implementation.process(@input).should == 'results'
  end
end