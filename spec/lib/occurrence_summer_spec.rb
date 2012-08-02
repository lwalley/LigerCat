# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require "occurrence_summer"

describe OccurrenceSummer do

  it "should sum occurrences based on the to_s method" do
    s = OccurrenceSummer.new(:to_s)
    s.sum %w(one two three two one)
    s.occurrences.should == { 'one' => 2, 'two' => 2, 'three' => 1 }
  end
  
  it "should sum occurrences based on the object_id" do
    s = OccurrenceSummer.new(:object_id)
    s1= 'one'
    s2= 'two'
    s.sum [s1, s1, s1, s1, s2, s2]
    s.occurrences.should == { s1.object_id => 4, s2.object_id => 2}
  end
  
  it "should sum using to_s by default" do
    s = OccurrenceSummer.new
    s.sum %w(one two three two one)
    s.occurrences.should == { 'one' => 2, 'two' => 2, 'three' => 1 }
  end
end

describe OccurrenceSummer, '#sum' do
  before(:each) do
    @s = OccurrenceSummer.new(:to_s)
  end
  
  it "should accept a single item" do
    @s.sum 'one'
    @s.sum 'one'
    @s.sum 'three'
    @s.occurrences.should == { 'one' => 2, 'three' => 1 }
  end
  
  it "should accept an array" do
    @s.sum ['dude', 'bro', 'brodude', 'dudebro', 'dude']
    @s.occurrences.should == {'dude' => 2, 'bro' => 1, 'brodude' => 1, 'dudebro' => 1}
  end
end