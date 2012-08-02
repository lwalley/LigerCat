require 'spec_helper'
require 'shared/keyword_frequency'

describe JournalTextFrequency, "#frequencies_for_journals" do
  fixtures :journals, :journal_text_frequencies, :text_keywords
  
  it_should_behave_like 'A KeywordFrequency'
  
  
  before(:each) do
    @journal_ids = [journals(:nature).id, journals(:science).id]
    @keyword_freqs = JournalTextFrequency.find_frequencies_for_journals(@journal_ids)
    @freq = JournalTextFrequency.new
  end
  
  it "should select name, frequency, and score" do
    @keyword_freqs.first.attributes.should have_key('name')
    @keyword_freqs.first.attributes.should have_key('frequency')
    @keyword_freqs.first.attributes.should have_key('score')
  end
  
  it "should properly group the keywords" do
    @keyword_freqs.length.should have(4).items
  end
  
  it "should sum the frequencies by name" do
    @keyword_freqs.each do |kwf|
      case kwf.name
      when text_keywords(:bread).name
        kwf.frequency.should == journal_text_frequencies(:science_bread).frequency + journal_text_frequencies(:nature_bread).frequency
      when text_keywords(:peanut_butter).name
        kwf.frequency.should == journal_text_frequencies(:science_peanut_butter).frequency + journal_text_frequencies(:nature_peanut_butter).frequency
      when text_keywords(:jam).name
         kwf.frequency.should == journal_text_frequencies(:science_jam).frequency
      when text_keywords(:jelly).name
        kwf.frequency.should == journal_text_frequencies(:nature_jelly).frequency
      end
    end
  end
  
end
