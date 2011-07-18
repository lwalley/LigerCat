# -*- Mode: RSpec; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require "#{RAILS_ROOT}/lib/mesh_frequency_calculator"
require File.dirname(__FILE__) + '/../mocked_eutils_responses'

class MeshFrequencyCalculator
  attr_accessor :pmids_without_mesh_annotations, :mesh_freqs
  def public_find_local_mesh_terms; find_local_mesh_terms; end 
  def public_retrieve_unannotated_pmids; retrieve_unannotated_pmids; end 
end


describe "MeshFrequencyCalculator" do
  fixtures :pubmed_queries, :pmids_mesh_keywords, :mesh_keywords
  
  before(:each) do
    # Stub out the EUtils calls
    Net::HTTP.stub!(:get_response).and_return(mock("Mocked HTTP Response", :body => MockedEutilsResponses::BIODIVERSITY_INFORMATICS_EFETCH_PMIDS_WITHOUT_MESH))
    
    @esearch_pmids = [18784790, 18483570, 18445641, 18335319, 17704120, 17597923, 17594421, 16956323, 16701313, 16680511, 15253354, 15192219, 15063059, 12376687, 11009408] # these came straight out of the XML file
    @pmids_without_mesh = [18784790, 18483570, 18335319, 17704120, 17597923, 16701313]
    
    @stop_terms = [mesh_keywords(:biodiversity), mesh_keywords(:informatics)]
    
    @frequency_calculator = MeshFrequencyCalculator.new(@esearch_pmids, 0.4, @stop_terms)
  end
  
  describe '#initialize' do
    it "should accept a list of PMIDs, an e-value, and a list of MeshKeyword stop terms" do
      @frequency_calculator.pmids.should == @esearch_pmids
      @frequency_calculator.e_value_threshold.should == 0.4
      @frequency_calculator.stop_terms.should == [mesh_keywords(:biodiversity), mesh_keywords(:informatics)]
    end
  end
  
  describe '#find_local_mesh_terms' do
    it "should find MeshKeywords for the given pmids, if available" do
      @esearch_pmids.each do |pmid|
        MeshKeyword.should_receive(:find_all_by_pmid).with(pmid).and_return([mock_model(MeshKeyword)])
      end
      
      @frequency_calculator.public_find_local_mesh_terms
    end
    
    it "should keep track of the pmids for which we don't have any mesh terms" do
      @frequency_calculator.public_find_local_mesh_terms
      @frequency_calculator.pmids_without_mesh_annotations.should == @pmids_without_mesh
    end
    
    it "should sum the occurrence of the found mesh keywords unless they are a stop term" do
      @frequency_calculator.public_find_local_mesh_terms
      @frequency_calculator.mesh_freqs.occurrences.should_not be_empty
      @frequency_calculator.mesh_freqs.occurrences.should_not have_key mesh_keywords(:biodiversity).id #stop term
      @frequency_calculator.mesh_freqs.occurrences.should_not have_key mesh_keywords(:informatics).id  #stop term
    end
  end
  
  describe '#retrieve_unannotated_pmids' do
    before(:each) do
      PmidsMeshKeyword.stub!(:bulk_insert)  # this is so we don't accidentally change the test state. The DB tables won't get wiped out each time.
      @frequency_calculator.pmids_without_mesh_annotations = @pmids_without_mesh
    end
    
    it "should create a MeshSearch to retrieve the mesh ids we don't have locally" do
      @mocked_mesh_search = mock("Mocked MeshSearch")
      MeshSearch.should_receive(:new).and_return @mocked_mesh_search
      @mocked_mesh_search.should_receive(:search).with(@pmids_without_mesh).and_return({})
      
      @frequency_calculator.public_retrieve_unannotated_pmids
    end
    
    it "should sum the occurrence of the found mesh keywords unless they are a stop term" do
      # PMID 17704120 did not have any MeSH terms in the database, but did have some returned in the MeshSearch
      mesh_terms_for_17704120 = [mesh_keywords(:biodiversity), # This is a stop term
                                 mesh_keywords(:computational_biology),
                                 mesh_keywords(:databases_genetic),
                                 mesh_keywords(:information_dissemination),
                                 mesh_keywords(:population_dynamics)]
      
      mesh_terms_for_17704120_minus_stop_terms = [ mesh_keywords(:computational_biology), mesh_keywords(:databases_genetic), mesh_keywords(:information_dissemination), mesh_keywords(:population_dynamics)]
      
      @frequency_calculator.mesh_freqs = OccurrenceSummer.new
      @frequency_calculator.mesh_freqs.should_receive(:sum).with(mesh_terms_for_17704120_minus_stop_terms)
      @frequency_calculator.public_retrieve_unannotated_pmids
    end
    
    it "should add the found mesh keywords into the database" do
      PmidsMeshKeyword.should_receive(:bulk_insert)
      @frequency_calculator.mesh_freqs = OccurrenceSummer.new
      @frequency_calculator.public_retrieve_unannotated_pmids
    end
  end
end