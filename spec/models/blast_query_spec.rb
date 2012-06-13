require File.dirname(__FILE__) + '/../spec_helper'
require "#{RAILS_ROOT}/lib/blast"

describe "A BlastQuery" do
  it_should_behave_like "An Asynchronous Query"
  
  before(:each) do
    Resque.stub!(:enqueue)
    @query = BlastQuery.new(:fasta_data => ">gi|2138274|gb|U76735.1|SCU76735\natcgatcg")
  end
  

  describe 'A new BlastQuery' do
    it "should generate a query_key before creating the object" do
      bq = BlastQuery.create(:fasta_data => ">gi|2138274|gb|U76735.1|SCU76735\natcgatcg")
      bq.query_key.should == "eef04a8cea94e1dd5b08bb3d482c7246"
    end
  
    it "should create a new Sequence with the fasta data" do
      Sequence.should_receive(:new).with(:fasta_data => ">gi|2138274|gb|U76735.1|SCU76735\natcgatcg").and_return(mocked_sequence = mock_model(Sequence, :[]= => 'attrs', :[] => 'attrs', :save => true))
      bq = BlastQuery.create(:fasta_data => ">gi|2138274|gb|U76735.1|SCU76735\natcgatcg")
    
      bq.sequence.should == mocked_sequence
    end
  end

  describe "An invalid BlastQuery" do
    before(:each) do
      @query.fasta_data = nil
    end
    
    it "should not save" do
      @query.save.should be_false
    end
  
    it "should not launch a BlastWorker" do
      Resque.should_not_receive(:enqueue)
      @query.save
    end
  end 

  def find_by_sequence(fasta_data)
    find_by_query_key create_query_key(fasta_data)
  end

  describe 'BlastQuery.find_by_sequence' do
    before(:each) do
      @fasta_data = "ATCTDNSDFNSDFSDN"
    end

    it "should call find_by_query_key with the MD5'd fasta_data" do
      BlastQuery.should_receive(:find_by_query_key).with( BlastQuery.create_query_key @fasta_data )
      BlastQuery.find_by_sequence(@fasta_data)
    end
  end

  describe "BlastQuery#perform_query!" do
    fixtures :sequences
  
    before(:each) do
      @query = BlastQuery.new
      @query.sequence = sequences(:app)
      @query.stub!(:save) # Save is called at the end of perform_query, and I don't want to deal with that DB write
    end
  
    # We're going to create a mocked LigerEngine here to prevent it from running.
    # Danger danger!
    before(:each) do
      @mocked_liger_engine = mock("LigerEngine", :add_observer => nil )
      @mocked_liger_engine.stub!(:run).and_return(OpenStruct.new(:tag_cloud => [], :histogram => []))
    
      LigerEngine::Engine.stub!(:new).and_return(@mocked_liger_engine)
    end
  
    after(:each) do
      @query.perform_query!
    end
  
    it "should instantiate an amino acid search strategy given an amino acid Sequence" do
      @query.sequence = sequences(:an_amino_acid)
      LigerEngine::SearchStrategies::GenbankSearchStrategy.should_receive(:new).with(:amino_acid)
    end
  
    it "should instantiate a nucleotide search strategy given a nucleotide Sequence" do
      @query.sequence = sequences(:a_nucleotide)
      LigerEngine::SearchStrategies::GenbankSearchStrategy.should_receive(:new).with(:nucleotide)
    end
  
    it "should create a LigerEngine with a Genbank search and a composite processor and let it run" do
      LigerEngine::Engine.should_receive(:new).with(an_instance_of(LigerEngine::SearchStrategies::GenbankSearchStrategy),
                                                    an_instance_of(LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor) ).and_return(@mocked_liger_engine = mock("LigerEngine", :add_observer => nil))

      @mocked_liger_engine.should_receive(:run).with( @query.sequence.fasta_data ).and_return(OpenStruct.new(:tag_cloud => [], :histogram => []))
    end
  end

  describe 'BlastQuery.create_query_key' do
    before(:each) do
      @query = "    This is a happy litle query string. ATCG ATCG    "
    end
  
    it "should strip, downcase, and run the query through MD5" do
      BlastQuery.create_query_key(@query).should == Digest::MD5.hexdigest(@query.strip.downcase)
    end
  end
end