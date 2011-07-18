# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require "#{RAILS_ROOT}/test/bdrb_test_helper.rb"
require "#{RAILS_ROOT}/lib/workers/pubmed_worker"

describe 'PubmedWorker#execute_search' do
  before(:each) do
    @worker = PubmedWorker.new
    @worker.stub!(:exit)
    
    @query = mock_model(PubmedQuery)
    @query.stub!(:search!)
    @query.stub!(:update_attribute)
    @query.stub!(:perform_query!)
    
    PubmedQuery.stub!(:find).and_return(@query)
  end
  
  after(:each) do
    @worker.execute_search(1)
  end
  
  it "should find the PubmedQuery in question" do
    PubmedQuery.should_receive(:find).with(1).and_return(@query)
  end

  it "should call the perform_query! method on the PubmedQuery" do
    @query.should_receive(:perform_query!)
  end
  
  it "should update the PubmedQuery.done flag to true" do
    @query.should_receive(:update_attribute).with(:done, true)
  end
  
  it "should exit when done" do 
    @worker.should_receive(:exit)
  end
end