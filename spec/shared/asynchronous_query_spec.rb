require File.dirname(__FILE__) + '/../spec_helper'

describe "An Asynchronous Query", :shared => true do
  before :each do
    Resque.stub!(:enqueue)
  end
  
  it "should define self.queue" do
    @query.class.queue.should == :ligercat
  end
  
  it "should define self.perform" do
    @query.class.should respond_to(:perform)
  end
  
  it "should respond to perform_query!" do
    @query.should respond_to(:perform_query!)
  end
  
  describe '#done' do
    it "should return true if state is :cached or :queued_for_update" do
      AsynchronousQuery::STATES.each do |state_symbol, state_int| 
        @query.state = state_symbol
        
        case state_symbol
        when :cached, :queued_for_update
          @query.done?.should be_true
        else
          @query.done?.should be_false
        end
      end
    end
  end

  describe '#launch_worker' do
    it "should enqueueueue with Resque" do
      Resque.should_receive(:enqueue).with(@query.class, @query.id)
      @query.launch_worker
    end
    
    it "should update state to queued" do
      @query.state.should_not == :queued
      @query.launch_worker
      @query.state.should == :queued
    end
  end
  
  describe '#state' do
    it "should return the symbol version of the state integer code stored in the database" do
      
      AsynchronousQuery::STATES.each do |state_sym, state_int|
        
        @query.write_attribute(:state, state_int)
        @query.state.should == state_sym
        
      end
    end
  end
  
  describe '#state=' do
    it "should accept a state symbol and assign the integer code" do
      AsynchronousQuery::STATES.each do |state_sym, state_int|
        
        @query.state = state_sym
        @query.read_attribute(:state).should == state_int
      end
    end
    
    it "should throw an ArgumentError if given a symbol that is not a valid state symbol" do
      expect{ @query.state = :chernobyl }.to raise_error(ArgumentError)
    end
    
  end
  
  describe '#update_state' do
    
    before(:each) do
      @query.save
    end
    
    it "should throw an ArgumentError if given a symbol that is not a valid state symbol" do
      expect{ @query.update_state :chernobyl }.to raise_error(ArgumentError)
    end

    it "should log the state change" do
      RAILS_DEFAULT_LOGGER.should_receive(:info).at_least(:once).with(/queued/)
      @query.update_state(:queued)
    end
    
    it "should update the state attribute with the appropriate integer code" do      
      AsynchronousQuery::STATES.each do |state_sym, state_int|
        
        @query.update_state state_sym
        @query.read_attribute(:state).should == state_int
      end
      
    end
  end
  
end