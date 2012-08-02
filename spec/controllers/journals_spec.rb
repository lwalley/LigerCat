require 'spec_helper'

describe JournalsController, "#index without any arguments" do
  render_views
  after(:each) do
    get :index
  end
  it "should not hit the Medline search" do
    NLMJournalSearch.should_not_receive(:new)
  end
end

describe JournalsController, "#index with a valid query parameter" do
  before(:each) do
    @query = mock_model(JournalQuery, :job_key => 'JournalQuery-1', :done? => false)
    MiddleMan.stub!(:ask_status)
  end
  
  after(:each) do
    get :index, {:q => 'aging'}
  end
  
  it "should hit the Medline search if JournalQuery does not exist in local db cache" do
    JournalQuery.should_receive(:find_by_query).and_return(nil)
    JournalQuery.should_receive(:create).and_return(@query)
  end
  
  it "should not hit Medline if JournalQuery exists in db cache" do
    JournalQuery.should_receive(:find_by_query).and_return(@query)
    NLMJournalSearch.should_not_receive(:new)
  end
end
