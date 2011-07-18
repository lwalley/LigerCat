require File.dirname(__FILE__) + '/../spec_helper'

describe "A KeywordFrequency", :shared => true do
  it "should respond to weighted_frequency" do
    @freq.should be_respond_to :weighted_frequency
  end
end