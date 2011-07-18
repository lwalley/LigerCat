require File.dirname(__FILE__) + '/../spec_helper'
require File.expand_path(File.dirname(__FILE__) + "/../shared/keyword_frequency_spec")

describe JournalMeshFrequency do
  before(:each) do
    @freq = JournalMeshFrequency.new
  end
  
  it_should_behave_like 'A KeywordFrequency'
end

describe JournalMeshFrequency, "#frequencies_for_journals" do
  fixtures :journals, :journal_mesh_frequencies, :mesh_keywords
  
  before(:each) do
    @journal_ids = [journals(:nature).id, journals(:science).id]
    @keyword_freqs = JournalMeshFrequency.find_frequencies_for_journals(@journal_ids)
  end
  
  it "should select name, frequency, and score" do
    @keyword_freqs.first.attributes.has_key?('name').should be_true
    @keyword_freqs.first.attributes.has_key?('frequency').should be_true
    @keyword_freqs.first.attributes.has_key?('score').should be_true
  end
  
  it "should properly group the keywords" do
    @keyword_freqs.should have(5).items
  end
  
  it "should sum the frequencies by name" do
    @keyword_freqs.each do |kwf|
      if kwf.name == 'Vanilla'
        kwf.frequency.should == journal_mesh_frequencies(:science_vanilla).frequency + journal_mesh_frequencies(:nature_vanilla).frequency
        break;
      end
    end
  end
end