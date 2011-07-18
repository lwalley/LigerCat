require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LigerEngine do
  describe '#initialize' do
    it "should check that the search and processing strategies are legit" do
      search_strategy     = LigerEngine::SearchStrategies::PubmedSearchStrategy.new
      processing_strategy = LigerEngine::ProcessingStrategies::HistogramProcessor.new
      
      lambda{ LigerEngine::Engine.new("not a search strategy", processing_strategy) }.should raise_error(ArgumentError, "Search Strategy must respond to :search")
      lambda{ LigerEngine::Engine.new(search_strategy, 'not a processing strategy') }.should raise_error(ArgumentError, "Processing Strategy must respond to :process")

      engine = LigerEngine::Engine.new(search_strategy, processing_strategy)
      engine.search_strategy.should == search_strategy
      engine.processing_strategy.should == processing_strategy
    end
  end
  
  describe '#run' do
    it "should call the search strategy, then the processing strategy, then return the results" do
      search_strategy     = mock("Search Stragegy",     :search => [123,456])
      processing_strategy = mock("Processing Strategy", :process => "Yeehaw!")
      
      engine = LigerEngine::Engine.new(search_strategy, processing_strategy)

      query  = "a query"
      
      search_strategy.should_receive(:search).with(query).and_return([123,456])
      processing_strategy.should_receive(:process).with([123,456]).and_return("Yeehaw!")
      
      engine.run(query).should == 'Yeehaw!'
    end
  end
end