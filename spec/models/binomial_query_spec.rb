require 'spec_helper'
require 'shared/asynchronous_query'


describe "A BinomialQuery" do
  fixtures :queries, :mesh_frequencies, :mesh_keywords
  before(:each) do
    @query = BinomialQuery.new :query => "some_query"
  end
  
  it_should_behave_like "An Asynchronous Query"

  it "should validate presence of 'query' attribute" do
    @query.query = ''
    @query.should_not be_valid
    @query.query = 'not blank'
    @query.should be_valid
  end

  describe "Fuck rspec x1000000" do
    it "should call launch_worker after create" do
      @brand_new_query = BinomialQuery.new(:query => 'shiny new query')
      @brand_new_query.should_receive(:launch_worker)
      @brand_new_query.save!
    end
  end
  
  it "should have mesh_frequencies" do
    queries(:binomial).mesh_frequencies.should_not be_blank
  end

  it "should have mesh_keywords" do
    queries(:binomial).mesh_keywords.should_not be_blank
  end
  
  it "should set the query key before commit" do
    @query.key.should be_blank #sanity check
    @query.save
    @query.key.should_not be_blank
  end
end

describe BinomialQuery, '.create_key' do
  before(:each) do
    @query = "    Mus musculus    "
  end

  it "should strip, downcase, and run the query through MD5" do
    BinomialQuery.create_key(@query).should == Digest::MD5.hexdigest(@query.strip.downcase)
  end
end

describe BinomialQuery, '.find_by_query' do
  before(:each) do
    @query = "Mus musculus"
  end

  it "should call find_by_key with the MD5'd query" do
    BinomialQuery.should_receive(:find_by_key).with( BinomialQuery.create_key @query )
    BinomialQuery.find_by_query(@query)
  end
end

describe BinomialQuery, '.find_or_create_by_query' do
  before(:each) do
    @query = "Mus musculus"
    Resque.stub!(:enqueue)
  end

  it "should call find_by_query, which abstracts the key thing" do
    BinomialQuery.should_receive(:find_by_query).with( @query )
    BinomialQuery.find_or_create_by_query(@query)
  end
end


describe BinomialQuery, "#actual_pubmed_query" do
  it "should run the query through BinomialSearchStrategy" do
    q = BinomialQuery.new(:query => "Mus musculus")

    expected_pubmed_query = LigerEngine::SearchStrategies::BinomialPubmedSearchStrategy::species_specific_query(q.query)

    q.actual_pubmed_query.should == expected_pubmed_query
  end
end


describe BinomialQuery, '#perform_query!' do
  before(:each) do
    @query = BinomialQuery.new(:query => 'Mus musculus')
    @query.stub!(:valid?).and_return(true)
    @query.stub!(:save)
  end

  # We're going to create a mocked LigerEngine here to prevent it from running.
  # Danger danger!
  before(:each) do
    @mocked_liger_engine = mock("LigerEngine")
    @mocked_liger_engine.stub!(:run).and_return(OpenStruct.new(:tag_cloud => [], :histogram => []))
    @mocked_liger_engine.stub!(:count).and_return(1234)
    @mocked_liger_engine.stub!(:add_observer)

    LigerEngine::Engine.stub!(:new).and_return(@mocked_liger_engine)
  end

  after(:each) do
    @query.perform_query!
  end

  it "should instantiate a Pubmed search strategy given a normal query" do
    LigerEngine::SearchStrategies::BinomialPubmedSearchStrategy.should_receive(:new)
  end

  it "should instantiate a new LigerEngine and let it run" do
    mocked_liger_engine = mock("LigerEngine")

    LigerEngine::Engine.should_receive(:new).with(an_instance_of(LigerEngine::SearchStrategies::BinomialPubmedSearchStrategy),
                                                  an_instance_of(LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor)).and_return(mocked_liger_engine)

    mocked_liger_engine.should_receive(:run).with('Mus musculus').and_return(OpenStruct.new(:tag_cloud => [], :histogram => []))
    mocked_liger_engine.should_receive(:count).and_return(17)
    mocked_liger_engine.stub!(:add_observer)
  end
end


describe BinomialQuery, '#slug' do
  before(:each) do
    @query = BinomialQuery.new
  end

  it "should replace special characters in a string so that it may be used as part of a pretty URL." do
    @query.query = "Mus musculus"
    @query.slug.should == "mus-musculus"
  end

  it "should trunctate a really long string to 100 characters" do
    @query.query = 'a' * 2000
    @query.slug.length.should == 100
  end
end

describe BinomialQuery, "#cache_webhook_uri" do
  before(:each) do
    @query = BinomialQuery.new()
    @query.id = 1234
  end
  it "should generate a URI to the PubmedQueriesController#cache route" do
    @query.cache_webhook_uri.should =~ /\/articles\/#{@query.id}\/cache/
  end
end


