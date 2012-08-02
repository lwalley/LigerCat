# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require "nlm_eutil_search"
require "mesh_search"
require File.dirname(__FILE__) + '/../mocked_eutils_responses'

describe 'MeshSearch' do
  before(:each) do
    @search = MeshSearch.new
    @search.skip_sleep = true
    Net::HTTP.stub!(:get_response).and_return(mock("Mocked HTTP Response", :body => MockedEutilsResponses::BIODIVERSITY_INFORMATICS_EFETCH))
  end
  
  describe '#search' do
    before(:each) do
      Net::HTTP.stub!(:get_response).and_return(mock("Mocked HTTP Response", :body => MockedEutilsResponses::BIODIVERSITY_INFORMATICS_EFETCH))
      @biodiversity_informatics_pmids = [18784790,18483570,18445641,18335319,17704120,17597923,17594421,16956323,16701313,16680511,15253354,15192219,15063059,12376687,11009408]
    end
    it "should accept an array of pmids and return a hash of mesh headings" do
      response = @search.search(@biodiversity_informatics_pmids)
      response.should == {17704120=>["Biodiversity", "Computational Biology", "Databases, Genetic", "Information Dissemination", "Population Dynamics"],
                          18445641=>["Computational Biology", "Database Management Systems", "Databases, Factual", "Documentation", "Information Storage and Retrieval", "Natural Language Processing", "Terminology as Topic"],
                          15063059=>["Bacteria", "Biodiversity", "Cluster Analysis", "Crops, Agricultural", "DNA Fingerprinting", "DNA, Bacterial", "Electrophoresis", "Electrophoresis, Polyacrylamide Gel", "Nucleic Acid Denaturation", "Soil Microbiology"],
                          15253354=>["Biodiversity", "Classification", "Computational Biology", "Demography", "Environment", "Geography"],
                          16680511=>["Bacterial Physiology", "Ecosystem", "Fungi", "Hydrophobicity", "Image Processing, Computer-Assisted", "Lolium", "Plant Roots", "Porosity", "Soil", "Soil Microbiology"],
                          11009408=>["Animals", "Classification", "Computational Biology", "Computer Communication Networks", "Databases, Factual", "Ecosystem", "Internet", "Plants", "Software", "Terminology as Topic"],
                          15192219=>["Animals", "Bacteria", "Bacterial Physiology", "Bacteriological Techniques", "Biodiversity", "Biophysics", "Chemistry, Physical", "Ecosystem", "Environment", "Fractals", "Fungi", "Models, Biological", "Mycology", "Soil", "Soil Microbiology"],
                          17594421=>["Biodiversity", "Conservation of Natural Resources", "Databases, Factual", "Ecology", "Informatics", "Interdisciplinary Communication", "Internet", "Research Design"],
                          12376687=>["Animals", "Biological Specimen Banks", "Classification", "Conservation of Natural Resources", "Costs and Cost Analysis", "Databases, Factual", "Developed Countries", "Developing Countries", "Ecosystem", "Evolution", "Financial Support", "International Cooperation", "Phylogeny", "Plants"],
                          16956323=>["Animals", "Biodiversity", "Databases as Topic", "Geography", "Informatics", "Insects", "Statistics as Topic"],
                          16701313=>[],
                          17597923=>[],
                          18335319=>[],
                          18483570=>[],
                          18784790=>[]}
    end
  end
  
  describe "#efetch_url" do
    it "should select rettype pubmed" do
      @search.terms = [123]
      @search.efetch_url.should == 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&rettype=pubmed&id=123'
    end
    it "should join terms with commas" do
      @search.terms = [123,456,789]
      @search.efetch_url.should == 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&rettype=pubmed&id=123,456,789'
    end
  end
  
  describe '#terms=' do
    before(:each) do
      @search.stub!(:efetch)
    end
    it "should convert terms into an array unless it is already" do
      @search.terms= [1,2,3]
      @search.terms.should == [1,2,3]
      
      @search.terms = 12345
      @search.terms.should == [12345]
    end
  end
  
  describe '#query_eutils' do
    before(:each) do
      @search.stub!(:efetch)
    end
    
    it "should set terms= to params" do
      @search.should_receive(:terms=).with([1,2,3])
      @search.query_eutils([1,2,3])
    end
    
    it "should call efetch" do
      @search.should_receive(:efetch)
      @search.query_eutils(123)
    end
    
    it "should not call esearch" do
      @search.should_not_receive(:esearch)
      @search.query_eutils(1234)
    end
  end
  
  describe '#parse_efetch_response' do
    it "should receive the response body from params" do
      @search.should_receive(:parse_efetch_response).with(MockedEutilsResponses::BIODIVERSITY_INFORMATICS_EFETCH)
      @search.query_eutils(123)
    end
    
    it "should return a hash associating the given pmids with their mesh terms" do
      Net::HTTP.stub!(:get_response).and_return(mock("Mocked HTTP Response", :body => MockedEutilsResponses::BIODIVERSITY_INFORMATICS_EFETCH))
      biodiversity_informatics_pmids = [18784790,18483570,18445641,18335319,17704120,17597923,17594421,16956323,16701313,16680511,15253354,15192219,15063059,12376687,11009408]

      response = @search.query_eutils(biodiversity_informatics_pmids)
      response.keys.length.should == biodiversity_informatics_pmids.length
      
      response.should == {17704120=>["Biodiversity", "Computational Biology", "Databases, Genetic", "Information Dissemination", "Population Dynamics"],
                          18445641=>["Computational Biology", "Database Management Systems", "Databases, Factual", "Documentation", "Information Storage and Retrieval", "Natural Language Processing", "Terminology as Topic"],
                          15063059=>["Bacteria", "Biodiversity", "Cluster Analysis", "Crops, Agricultural", "DNA Fingerprinting", "DNA, Bacterial", "Electrophoresis", "Electrophoresis, Polyacrylamide Gel", "Nucleic Acid Denaturation", "Soil Microbiology"],
                          15253354=>["Biodiversity", "Classification", "Computational Biology", "Demography", "Environment", "Geography"],
                          16680511=>["Bacterial Physiology", "Ecosystem", "Fungi", "Hydrophobicity", "Image Processing, Computer-Assisted", "Lolium", "Plant Roots", "Porosity", "Soil", "Soil Microbiology"],
                          11009408=>["Animals", "Classification", "Computational Biology", "Computer Communication Networks", "Databases, Factual", "Ecosystem", "Internet", "Plants", "Software", "Terminology as Topic"],
                          15192219=>["Animals", "Bacteria", "Bacterial Physiology", "Bacteriological Techniques", "Biodiversity", "Biophysics", "Chemistry, Physical", "Ecosystem", "Environment", "Fractals", "Fungi", "Models, Biological", "Mycology", "Soil", "Soil Microbiology"],
                          17594421=>["Biodiversity", "Conservation of Natural Resources", "Databases, Factual", "Ecology", "Informatics", "Interdisciplinary Communication", "Internet", "Research Design"],
                          12376687=>["Animals", "Biological Specimen Banks", "Classification", "Conservation of Natural Resources", "Costs and Cost Analysis", "Databases, Factual", "Developed Countries", "Developing Countries", "Ecosystem", "Evolution", "Financial Support", "International Cooperation", "Phylogeny", "Plants"],
                          16956323=>["Animals", "Biodiversity", "Databases as Topic", "Geography", "Informatics", "Insects", "Statistics as Topic"],
                          16701313=>[],
                          17597923=>[],
                          18335319=>[],
                          18483570=>[],
                          18784790=>[]}
    end
  end
end