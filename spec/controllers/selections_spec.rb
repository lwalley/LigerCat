require File.dirname(__FILE__) + '/../spec_helper'

describe SelectionsController, '#create' do
  before(:each) do
    Journal.stub!(:find).and_return(mock_model(Journal))
  end
  
  it "should add the journal id to the session contents" do
    session[:selections] = [67890]
    
    post :create, :journal_id => '12345'
    session[:selections].should == [67890, 12345]
  end
  
  it "should not duplicate entries in the session" do
    session[:selections] = [12345, 67890]
    
    post :create, :journal_id => '12345'
    session[:selections].should == [12345, 67890]
  end
  
  it "should accept multiple ids" do
    session[:selections] = [67890]
    
    post :create, :journal_id => '111;222;333'
    session[:selections].should == [67890,111,222,333]
  end
end

describe SelectionsController, '#destroy' do
  it "should remove an item from the session contents" do
    session[:selections] = [12345, 45678]
    delete :destroy, :id => 12345
    session[:selections].should_not include(12345)
  end
end

describe SelectionsController, '#destroy_all' do
  it "should remove all items from the session contents" do
    session[:selections] = [12345, 45678]
    delete :destroy_all
    session[:selections].should be_empty
  end
end

describe SelectionsController, '#destroy_some' do
  before(:each) do
    session[:selections] = [123, 456, 789, 10]
  end
  
  it "should remove the specified items from the session contents" do
    delete :destroy_some, :journal_id => '123'
    session[:selections].should == [456, 789, 10]
  end
  
  it "should remove multiple items from the session contents" do
    delete :destroy_some, :journal_id => '123;456'
    session[:selections].should == [789, 10]
  end
end
