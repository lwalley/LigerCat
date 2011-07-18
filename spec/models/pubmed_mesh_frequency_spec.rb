require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + "/../shared/keyword_frequency_spec")

describe PubmedMeshFrequency do
  fixtures :mesh_keywords, :pubmed_queries

  it_should_behave_like 'A KeywordFrequency'
  
  before(:each) do
    @freq = PubmedMeshFrequency.create({:mesh_keyword_id => mesh_keywords(:animals).id, :pubmed_query_id => pubmed_queries(:biodiversity_informatics).id, :frequency => 2})
  end
  
  it "should belong to a MeshKeyword" do
    @freq.mesh_keyword.should == mesh_keywords(:animals)
  end
  
  it "should belong to a PubmedQuery" do
    @freq.pubmed_query.should == pubmed_queries(:biodiversity_informatics)
  end
end
