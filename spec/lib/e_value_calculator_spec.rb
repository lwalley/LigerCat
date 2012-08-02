require 'spec_helper'
require "e_value_calculator"

describe EValueCalculator do
  before(:each) do
    @letter_freqs = {:a => 10, :b => 1, :c => 1, :d => 5, :e => 5, :f => 1 }
    @c = EValueCalculator.new(@letter_freqs, 0.1)
  end
  
  describe '#initialize' do
    it "should raise an error if the first argument is not a freq hash" do
      lambda{ EValueCalculator.new("DOOOD!!!OMFG!!", 0.02) }.should raise_error(ArgumentError)
      lambda{ EValueCalculator.new({"doood" => 'OMFG!!!!'}, 0.02) }.should raise_error(ArgumentError)
      lambda{ EValueCalculator.new({:dude => 1234, :omfg => 12}, 0.02) }.should_not raise_error
    end
  end
  
  describe '#each' do
    it "should yeild if e_value is less than the threshold" do
      m = mock("A Mock")
      
      m.should_receive(:validate).once.with(:a, 10, @c.e_value(10,1))
      m.should_receive(:validate).once.with(:d, 5,  @c.e_value(5,2))
      m.should_receive(:validate).once.with(:e, 5,  @c.e_value(5,2))
      
      m.should_not_receive(:validate).with(:b, 1, anything)
      m.should_not_receive(:validate).with(:c, 1, anything)
      m.should_not_receive(:validate).with(:f, 1, anything)
      
      c = EValueCalculator.new(@letter_freqs, 0.06)  
      c.each do |id, freq, e_val|
        m.validate(id, freq, e_val)
      end
    end
  end
  
  describe '#freq_occ' do
    it "should return the number of occurrences of the frequencies" do
      @c.freq_occ.should == {10 => 1,
                              1 => 3,
                              5 => 2 }
    end
  end
  
  describe '#sum_freq_occ' do
    it "should sum the freq * occ" do
      @c.sum_freq_occ.should == 10*1 + 1*3 + 5*2
    end
  end
  
  describe '#sum_freq' do
    it "should sum the freq's" do
      @c.sum_freq.should == 10 + 1 + 5
    end
  end
  
  describe '#lammy' do
    it "should be sum_freq_occ / sum_occ" do
      @c.lammy.should be_within(0.0001).of(1.4375)
    end
  end
  
  describe '#e_value' do
    it "should be computed correctly" do
      @c.e_value(10,1).should be_within(0.000000001).of(0.000000572)
      @c.e_value(1,3).should  be_within(0.0001).of(0.7126)
      @c.e_value(5,2).should  be_within(0.0001).of(0.0015)
    end
  end
  
end
