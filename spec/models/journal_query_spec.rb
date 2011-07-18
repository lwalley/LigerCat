require File.dirname(__FILE__) + '/../spec_helper'

describe "A JournalQuery" do
  it_should_behave_like "An Asynchronous Query"
  
  before(:each) do
    @query = JournalQuery.new
  end
  
  it "should call launch_worker after create" do
    @query.should_receive(:launch_worker)
    @query.query = 'Biodiversity informatics'
    @query.stub!(:valid?).and_return(true)
    @query.save
  end
end

describe JournalQuery, '.create_query_key' do
  before(:each) do
    @query = "    Biodiversity Informatics    "
  end
  
  it "should strip, downcase, and run the query through MD5" do
    JournalQuery.create_query_key(@query).should == Digest::MD5.hexdigest(@query.strip.downcase)
  end
end

describe JournalQuery, '.find_by_query' do
  before(:each) do
    @query = "biodiversity informatics"
  end

  it "should call find_by_query_key with the MD5'd fasta_data" do
    JournalQuery.should_receive(:find_by_query_key).with( JournalQuery.create_query_key @query )
    JournalQuery.find_by_query(@query)
  end
end

describe 'JournalQuery#perform_query!' do
  # This takes a hideous amount of mocks. 
  # It's very fragile, but I can't think of anything better :(
  before(:each) do
    # These mocks are for the NLM journal search, and the journal objects that come back
    @journal = mock_journal
    @nlm_results = [@journal, @journal]
    @nlm_journal_search = mock('NLMJournalSearch')
    @nlm_journal_search.stub!(:search).and_return(@nlm_results)
    NLMJournalSearch.stub!(:new).and_return(@nlm_journal_search)
    
    # These mocks are for has_many :results, and the result_map
    @results = mock("results")
    @results.stub!(:build).and_return(mock_result)

    # For has_many :journals
    @journal_results = @nlm_results
    Journal.stub!(:find).and_return(@journal_results)
    
    @query = JournalQuery.new
    @query.stub!(:results).and_return(@results)
    @query.stub!(:save)
  end
  after(:each) do
    @query.perform_query!
  end
  
  it "should perform an NLMJournalSearch" do
    NLMJournalSearch.should_receive(:new).and_return(@nlm_journal_search)
    @nlm_journal_search.should_receive(:search).and_return(@nlm_results)
  end
  
  it "should build a set of results objects" do
    @results.should_receive(:build).exactly(@nlm_results.length).times.and_return(mock_result)
  end
  
  it "should analyze the keywords associated with the results" do
    @journal.should_receive(:journal_mesh_frequencies).exactly(2*@nlm_results.length).times.and_return([])
    @journal.should_receive(:journal_text_frequencies).exactly(2*@nlm_results.length).times.and_return([])
  end
  
  it "should save the query" do
    @query.should_receive(:save)
  end
  
end

describe "JournalQuery#launch_worker" do
  before(:each) do
    @query = JournalQuery.new
    @query.id = 1
    
    @worker = mock('JournalWorker')
    @worker.stub!(:execute_search)
    MiddleMan.stub!(:new_worker)
    MiddleMan.stub!(:worker).and_return(@worker)
  end
  
  after(:each) do
    @query.launch_worker
  end
  
  it "should create a new JournalWorker" do
    MiddleMan.should_receive(:new_worker).with({:worker => :journal_worker, :job_key => @query.job_key})
  end
  
  it "should call execute_search on the new JournalWorker, passing in the query's id" do
    MiddleMan.should_receive(:worker).with(:journal_worker, @query.job_key).and_return(@worker)
    @worker.should_receive(:execute_search).with(@query.id)
  end
end

def mock_journal
  returning mock_model(Journal) do |j|  
    j.stub!(:rank).and_return(1)
    j.stub!(:journal_mesh_frequencies).and_return([])
    j.stub!(:journal_text_frequencies).and_return([])
  end
end

def mock_result
  returning mock_model(JournalResult) do |r|
    r.stub!(:mesh_score=)
    r.stub!(:text_score=)
  end
end
