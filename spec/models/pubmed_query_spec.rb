# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.dirname(__FILE__) + '/../mocked_eutils_responses'

describe "A PubmedQuery" do
  fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  
  it_should_behave_like "An Asynchronous Query"
  
  before(:each) do
    @query = PubmedQuery.new :query => "some_query"
  end
  
  it "should validate presence of 'query' attribute" do
    @query.query = ''
    @query.should_not be_valid
    @query.query = 'not blank'
    @query.should be_valid
  end
  
  it "should call launch_worker after create" do
    @query.should_receive(:launch_worker)
    @query.query = 'biodiversity informatics'
    @query.stub!(:valid?).and_return(true)
    @query.save
  end
  
  it "should have pubmed_mesh_frequencies" do
    pubmed_queries(:biodiversity_informatics).pubmed_mesh_frequencies.should_not be_blank
  end
  
  it "should have mesh_keywords" do
    pubmed_queries(:biodiversity_informatics).mesh_keywords.should_not be_blank
  end
end

describe PubmedQuery, '.create_query_key' do
  before(:each) do
    @query = "    Biodiversity Informatics    "
  end
  
  it "should strip, downcase, and run the query through MD5" do
    PubmedQuery.create_query_key(@query).should == Digest::MD5.hexdigest(@query.strip.downcase)
  end
end

describe PubmedQuery, '.find_by_query' do
  before(:each) do
    @query = "biodiversity informatics"
  end

  it "should call find_by_query_key with the MD5'd query" do
    PubmedQuery.should_receive(:find_by_query_key).with( PubmedQuery.create_query_key @query )
    PubmedQuery.find_by_query(@query)
  end
end

describe PubmedQuery, "#actual_pubmed_query" do
  it "should run the query through EolSearchStrategy if an EoL query" do
    normal_query = PubmedQuery.new(:query => "Mr. T")
    eol_query    = PubmedQuery.new(:query => "Mus musculus", :eol_taxa_id => 12345)
    
    expected_eol_query = LigerEngine::SearchStrategies::EolPubmedSearchStrategy::species_specific_query(eol_query.query)
    
    normal_query.actual_pubmed_query.should == normal_query.query
    eol_query.actual_pubmed_query.should_not == eol_query.query
    eol_query.actual_pubmed_query.should == expected_eol_query    
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
  
  it "should instantiate a Pubmed search strategy given a normal query" do
    LigerEngine::SearchStrategies::PubmedSearchStrategy.should_receive(:new)
  end
  
  it "should instantiate an EolPubmed search strategy given an EoL query" do
    # Make that burrito a Ranch burrito! Make that query an EoL query!
    @query.query = 'Castilia occidentalis'
    @query.eol_taxa_id = 155503
    @query.full_species_name = 'Castilia occidentalis Fassl 1912'
    
    LigerEngine::SearchStrategies::EolPubmedSearchStrategy.should_receive(:new)
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


describe PubmedQuery, '#perform_query! with an EOL query' do
  before(:each) do
    FakeWeb.allow_net_connect = false
    @query = PubmedQuery.new(:query => 'Castilia occidentalis', :eol_taxa_id => 1234535)
    @query.stub!(:save)
  end
  
  it "should instantiate a dudebro" do
    
  end
end

describe PubmedQuery, '#slug' do
  before(:each) do
    @query = PubmedQuery.new
  end
  
  it "should replace special characters in a string so that it may be used as part of a ‘pretty’ URL." do
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

