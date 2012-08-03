require 'spec_helper'

shared_examples_for "A KeywordFrequency" do
  it "should respond to weighted_frequency" do
    @freq.should be_respond_to :weighted_frequency
  end
end