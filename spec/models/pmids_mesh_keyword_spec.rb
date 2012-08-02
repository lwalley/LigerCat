require 'spec_helper'

describe PmidsMeshKeyword do
  fixtures :pmids_mesh_keywords, :mesh_keywords
  
  it "should have mesh_keywords" do
    keywords = PmidsMeshKeyword.find_all_by_pmid(15253354)
    keywords.length.should == 6
  end
end

describe PmidsMeshKeyword, '.bulk_insert' do
  fixtures :mesh_keywords
  
  before(:each) do
    @pmid = 123
    PmidsMeshKeyword.delete_all(['pmid = ?', @pmid])
  end

  it "should insert a single mesh ids" do
    PmidsMeshKeyword.bulk_insert(@pmid, 4567)
    
    pmk = PmidsMeshKeyword.find_all_by_pmid(@pmid)
    pmk.length.should == 1
    pmk.first.mesh_keyword_id.should == 4567
  end
  
  it "should insert a single MeshKeyword" do
    PmidsMeshKeyword.bulk_insert(@pmid, mesh_keywords(:plant_roots))
    
    pmk = PmidsMeshKeyword.find_all_by_pmid(@pmid)
    pmk.length.should == 1
    pmk.first.mesh_keyword_id.should == mesh_keywords(:plant_roots).id
  end
  
  it "should insert an array of mesh ids" do
    PmidsMeshKeyword.bulk_insert(@pmid, [4567, 890, @pmid4])
    
    pmks = PmidsMeshKeyword.find_all_by_pmid(@pmid)
    pmks.length.should == 3
    
    [4567, 890, @pmid4].each do |mesh_id|
      pmks.select{|pmk| pmk.mesh_keyword_id == mesh_id }.should_not be_blank
    end
  end
  
  it "should insert an array of MeshKeywords" do
    mesh_keywords = [mesh_keywords(:plant_roots), mesh_keywords(:internet), mesh_keywords(:ecosystem)]
    PmidsMeshKeyword.bulk_insert(@pmid, mesh_keywords)
    
    pmks = PmidsMeshKeyword.find_all_by_pmid(@pmid)
    pmks.length.should == 3
    
    mesh_keywords.each do |mesh_keyword|
      pmks.select{|pmk| pmk.mesh_keyword_id == mesh_keyword.id }.should_not be_blank
    end
  end
end
