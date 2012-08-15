require 'spec_helper'
require 'shared/asynchronous_query'


describe "A PubmedQuery" do
  fixtures :queries, :mesh_frequencies, :mesh_keywords
  before(:each) do
    @query = PubmedQuery.new :query => "some_query"
  end
  
  it_should_behave_like "An Asynchronous Query"

  it "should validate presence of 'query' attribute" do
    @query.query = ''
    @query.should_not be_valid
    @query.query = 'not blank'
    @query.should be_valid
  end

  it "should call launch_worker after create" do
    @brand_new_query = PubmedQuery.new(:query => 'shiny new query')
    @brand_new_query.should_receive(:launch_worker)
    @brand_new_query.save!
  end
  
  it "should have pubmed_mesh_frequencies" do
    queries(:biodiversity_informatics).mesh_frequencies.should_not be_blank
  end

  it "should have mesh_keywords" do
    queries(:biodiversity_informatics).mesh_keywords.should_not be_blank
  end
  
  it "should set the query key before commit" do
    @query.key.should be_blank #sanity check
    @query.save
    @query.key.should_not be_blank
  end
end

describe PubmedQuery, '.create_key' do
  before(:each) do
    @query = "    Biodiversity Informatics    "
  end

  it "should strip, downcase, and run the query through MD5" do
    PubmedQuery.create_key(@query).should == Digest::MD5.hexdigest(@query.strip.downcase)
  end
end

describe PubmedQuery, '.find_by_query' do
  before(:each) do
    @query = "biodiversity informatics"
  end

  it "should call find_by_key with the MD5'd query" do
    PubmedQuery.should_receive(:find_by_key).with( PubmedQuery.create_key @query )
    PubmedQuery.find_by_query(@query)
  end
end

describe PubmedQuery, '.find_or_create_by_query' do
  before(:each) do
    @query = "biodiversity informatics"
    Resque.stub!(:enqueue)
  end

  it "should call find_by_query, which abstracts the key thing" do
    PubmedQuery.should_receive(:find_by_query).with( @query )
    PubmedQuery.find_or_create_by_query(@query)
  end
end


describe PubmedQuery, "#actual_pubmed_query" do
  it "should return the query verbatim" do
    q = PubmedQuery.new(:query => "Mr. T")

    q.actual_pubmed_query.should == q.query
  end
end


describe PubmedQuery, '#perform_query!' do
  before(:each) do
    @query = PubmedQuery.new(:query => 'biodiversity informatics')
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

  it "should instantiate a Pubmed search strategy " do
    LigerEngine::SearchStrategies::PubmedSearchStrategy.should_receive(:new)
  end


  it "should instantiate a new LigerEngine and let it run" do
    mocked_liger_engine = mock("LigerEngine")

    LigerEngine::Engine.should_receive(:new).with(an_instance_of(LigerEngine::SearchStrategies::PubmedSearchStrategy),
                                                  an_instance_of(LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor)).and_return(mocked_liger_engine)

    mocked_liger_engine.should_receive(:run).with('biodiversity informatics').and_return(OpenStruct.new(:tag_cloud => [], :histogram => []))
    mocked_liger_engine.should_receive(:count).and_return(17)
    mocked_liger_engine.stub!(:add_observer)

  end
end

describe PubmedQuery, '#slug' do
  before(:each) do
    @query = PubmedQuery.new
  end

  it "should replace special characters in a string so that it may be used as part of a pretty URL." do
    @query.query = "George Clinton"
    @query.slug.should == "george-clinton"

    @query.query = "some query [tiab]"
    @query.slug.should == 'some-query-tiab'
  end

  it "should trunctate a really long string to 100 characters" do
    @query.query = 'a' * 2000
    @query.slug.length.should == 100
  end
end

describe PubmedQuery, "#cache_webhook_uri" do
  before(:each) do
    @query = PubmedQuery.new()
    @query.id = 1234
  end
  it "should generate a URI to the PubmedQueriesController#cache route" do
    @query.cache_webhook_uri.should =~ /\/articles\/#{@query.id}\/cache/
  end
end


