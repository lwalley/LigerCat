require 'spec_helper'

describe Journal, '#mesh_frequencies' do
  fixtures :journals, :journal_mesh_frequencies, :mesh_keywords
  
  before(:each) do
    @journal = journals(:nature)
    @mesh_frequencies = @journal.mesh_frequencies
  end
  
  it "should select name, frequency, and score" do
    @mesh_frequencies.first.attributes.should have_key('name')
    @mesh_frequencies.first.attributes.should have_key('frequency')
    @mesh_frequencies.first.attributes.should have_key('score')
  end
  
  it "should select only frequencies for its Journal instance" do
    @mesh_frequencies.each do |mf|
      %w(Sagittaria Vanilla Renilla).should include(mf.name)       # these are all the MeSH keywords for Nature
    end
  end
end

describe Journal, '#text_frequencies' do
  fixtures :journals, :journal_text_frequencies, :text_keywords
  
  before(:each) do
    @journal = journals(:nature)
    @text_frequencies = @journal.text_frequencies
  end
  
  it "should select name, frequency, and score" do
    @text_frequencies.first.attributes.should have_key('name')
    @text_frequencies.first.attributes.should have_key('frequency')
    @text_frequencies.first.attributes.should have_key('score')
  end
  
  it "should select only frequencies for its Journal instance" do
    @text_frequencies.each do |tf|
      ['Bread', 'Peanut Butter', 'Jelly'].should include(tf.name)       # these are all the Text keywords for Nature
    end
  end
end

describe Journal, '#title_abbreviation' do
  before(:each) do
    @with_abbreviation = Journal.new(:title => 'Acta Gerontologica', :title_abbreviation => 'Act Geron')
    @sans_abbreviation = Journal.new(:title => 'The Proceedings of Hoseheads Anonymous')
  end
  
  it "should return abbreviated title if it exists" do
    @with_abbreviation.title_abbreviation.should == 'Act Geron'
  end
  
  it "should return the full title if no abbreviation exists" do
    @sans_abbreviation.title_abbreviation.should == 'The Proceedings of Hoseheads Anonymous'
  end
end
