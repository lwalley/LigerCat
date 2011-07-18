require File.dirname(__FILE__) + '/../spec_helper'

describe JournalQueriesController, '#show' do
  integrate_views
  
  before(:each) do
    @journal_query = mock_model(JournalQuery)
    @journal_query.stub!(:done?)
    @journal_query.stub!(:job_key).and_return('JournalQuery-1')
    @journal_query.stub!(:query).and_return('my happy query')
    JournalQuery.stub!(:find).and_return(@journal_query)
    MiddleMan.stub!(:ask_status)
  end
  
  it "should test to see if the JournalQuery is done" do
    @journal_query.should_receive(:done?)
    get :show, :id=>'1'
  end
  
  it "should get status from MiddleMan if JournalQuery is not done" do
    @journal_query.should_receive(:done?).and_return(false)
    MiddleMan.should_receive(:ask_status).with({:worker => :journal_worker, :job_key => @journal_query.job_key})
    get :show, :id=>'1'
  end
  
  it "should redirect if JournalQuery is done" do
    @journal_query.should_receive(:done?).and_return(true)
    get :show, :id=>'1'
    response.should be_redirect
  end
end