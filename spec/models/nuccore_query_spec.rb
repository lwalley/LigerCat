require File.dirname(__FILE__) + '/../spec_helper'

describe "A NuccoreQuery" do
  it_should_behave_like "An Asynchronous Query"
  
  before(:each) do
    @query = NuccoreQuery.new
  end
  
  it "should validate presence of 'query' attribute" do
    @query.query = ''
    @query.should_not be_valid
    @query.query = 'not blank'
    @query.should be_valid
  end
  
  it "should call launch_worker after create" do
    @query.should_receive(:launch_worker)
    @query.stub!(:valid?).and_return(true)
    @query.save
  end
end

describe 'NuccoreQuery#perform_query!' do
  before(:each) do
    @query = NuccoreQuery.new
    
    @nuccore_results = [12345, 678910]
    
    @nuccore_search = mock('NuccoreSearch Mock')
    @nuccore_search.stub!(:search).and_return(@nuccore_results)
    
    NuccoreSearch.stub!(:new).and_return(@nuccore_search)
    
    @sequence = mock_model(Sequence)
    Sequence.stub!(:find_or_create_by_id).and_return(@sequence)
    @query.nuccore_results.stub!(:create)
  end
  
  after(:each) do
    @query.perform_query!
  end
  
  it "should instantiate a new NuccoreSearch" do
    NuccoreSearch.should_receive(:new).and_return(@nuccore_search)
  end
  
  it 'should perform a NuccoreSearch#search' do
    @nuccore_search.should_receive(:search).and_return(@nuccore_results)
  end
  
  it "should create new NuccoreResults" do
    @sequence = mock_model(Sequence)
    Sequence.should_receive(:find_or_create_by_id).twice.and_return(@sequence)
    @query.nuccore_results.should_receive(:create).twice.with({:sequence_id => @sequence.id})
  end
end

describe "NuccoreQuery#launch_worker" do
  before(:each) do
    @query = NuccoreQuery.new
    @query.id = 1
    
    @worker = mock('NuccoreWorker')
    @worker.stub!(:execute_search)
    MiddleMan.stub!(:new_worker)
    MiddleMan.stub!(:worker).and_return(@worker)
  end
  
  after(:each) do
    @query.launch_worker
  end
  
  it "should create a new NuccoreWorker" do
    MiddleMan.should_receive(:new_worker).with({:worker => :nuccore_worker, :job_key => @query.job_key})
  end
  
  it "should call execute_search on the new NuccoreWorker, passing in the query's id" do
    MiddleMan.should_receive(:worker).with(:nuccore_worker, @query.job_key).and_return(@worker)
    @worker.should_receive(:execute_search).with(@query.id)
  end
end