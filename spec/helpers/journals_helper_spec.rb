require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JournalsHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(JournalsHelper)
  end

	describe '#journal_join_and_truncate' do
		before(:all) do
		  @journal_titles = ["Acta radiologica: therapy, physics, biology", "Acta paediatrica Scandinavica", "Acta medica veterinaria", "Acta paediatrica", "Acta pharmaceutica Suecica", "Acta psychotherapeutica et psychosomatica", "Acta radiologica", "Advances in radiation biology", "Advances in oral biology", "Advances in lipid research"]
			@journal_title_lengths = @journal_titles.map{|t| t.length} # [43, 29, 23, 16, 26, 41, 16, 29, 24, 26]
		end
		
	  it "should take a list of journal titles and join them all with join_string GIVEN a length that they all fit within" do
	    helper.journal_join_and_truncate(@journal_titles, 3000).should == @journal_titles.join(', ')
	  end
	
		it "should join the titles that do fit followed by truncate_string GIVEN a length that doesn't fit all journals" do
	  	helper.journal_join_and_truncate(@journal_titles, 40, ', ', 'and others').should == "#{@journal_titles.first}, and others"
			helper.journal_join_and_truncate(@journal_titles, 50, ', ', 'and others').should == "#{@journal_titles[0]}, #{@journal_titles[1]}, and others"
		end
	end
end
