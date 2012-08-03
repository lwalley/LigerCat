require 'spec_helper'

shared_examples_for 'A Search Strategy' do
  it "should respond to #search" do
    check_for_strategy_instance
    @strategy.should be_respond_to :search
  end
  
  describe "#search" do
    it "should accept a query as a parameter and return an array of integers (PMIDS)" do
      check_for_strategy_instance
      
      results = @strategy.search(@query)
      results.should be_a Array
      results.should_not be_empty
      results.all?{|r| r.is_a? Integer}.should be_true, "Expected an array of Integers"
    end
  end
end

def check_for_strategy_instance
  @strategy.should_not(be_nil, "You must set the instance variable @strategy for the shared examples to work")
end