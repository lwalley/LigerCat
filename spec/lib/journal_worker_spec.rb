# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require "#{RAILS_ROOT}/test/bdrb_test_helper.rb"
require "#{RAILS_ROOT}/lib/workers/journal_worker"

describe 'JournalWorker#execute_search' do
  before(:each) do
    @worker = JournalWorker.new
    @worker.stub!(:exit)
    
    @query = mock_model(JournalQuery)
    @query.stub!(:search!)
    @query.stub!(:update_attribute)
    @query.stub!(:perform_query!)
    
    JournalQuery.stub!(:find).and_return(@query)
  end
  
  after(:each) do
    @worker.execute_search(1)
  end
  
  it "should find the JournalQuery in question" do
    JournalQuery.should_receive(:find).with(1).and_return(@query)
  end
  
  it "should call the perform_query! method on the JournalQuery" do
    @query.should_receive(:perform_query!)
  end
  
  it "should update the JournalQuery.done flag to true" do
    @query.should_receive(:update_attribute).with(:done, true)
  end
  
  it "should exit when done" do 
    @worker.should_receive(:exit)
  end
end