require 'spec_helper'

describe PublicationDate do
  before(:each) do
    @invalid_attributes = {}
    @valid_attributes = {:query_id => 1, :query_type => 'BlastQuery', :year => 2008, :publication_count => 3}
  end

  it "should create a new instance given valid attributes" do
    @date = PublicationDate.new(@invalid_attributes)
    @date.should_not be_valid
    @valid_attributes.keys.each do |k|
      @date.errors.should have_key(k)
    end
    @date.update_attributes(@valid_attributes)
    @date.should be_valid

    @date.year = 'A year'
    @date.should_not be_valid
    @date.errors.should have_key(:year)

    @date.publication_count = 'A count'
    @date.should_not be_valid
    @date.errors.should have_key(:publication_count)

  end
end
