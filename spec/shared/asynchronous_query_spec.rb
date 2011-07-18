require File.dirname(__FILE__) + '/../spec_helper'

describe "An Asynchronous Query", :shared => true do
  it "should have a valid job_key" do
    @query.job_key.should == "#{@query.class.name}-#{@query.id}"
  end
  
  it "should respond to perform_query!" do
    @query.should respond_to(:perform_query!)
  end
  
  it "should have a 'done' attribute" do
    @query.done?.should be_false
  end
end