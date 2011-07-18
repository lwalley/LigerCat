require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MeshKeyword do
  
  describe '.find_all_by_pmid' do
    fixtures :pmids_mesh_keywords, :mesh_keywords
    
    it "should load mesh keywords for a single pmid" do
      keywords = MeshKeyword.find_all_by_pmid(15253354)
      keywords.length.should == 6
      keywords.should be_include mesh_keywords(:biodiversity)
      keywords.should be_include mesh_keywords(:classification)
      keywords.should be_include mesh_keywords(:computational_biology)
      keywords.should be_include mesh_keywords(:demography)
      keywords.should be_include mesh_keywords(:environment)
      keywords.should be_include mesh_keywords(:geography)
    end
    
    it "should load mesh keywords for an array of pmids" do
      keywords = MeshKeyword.find_all_by_pmid([15253354, 11009408])
      keywords.length.should == 16
    end
  end
  
  describe '#to_i' do
    it "should return the PMID as an Integer" do
      keyword = MeshKeyword.find(:first)
      
      keyword.to_i.should == keyword.id
      keyword.to_i.should be_a Integer
    end
  end
  
end