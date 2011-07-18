# My oh my this class has a wacky API. 
# Really needs a refactor and some design pattern love...

class MeshFrequencyCalculator
  attr_reader :pmids_without_mesh_annotations,
              :mesh_freqs,
              :pmids,
              :e_value_threshold,
              :stop_terms

  # stop_terms should be an array of MeshKeyword objects
  def initialize(pmids, e_value_threshold, stop_terms)
    @pmids = pmids
    @e_value_threshold = e_value_threshold
    @stop_terms = stop_terms
    @pmids_without_mesh_annotations = []
  end
  
  def each_mesh_freq(&block)
    find_local_mesh_terms
    
    retrieve_unannotated_pmids
    
    mesh_below_e_threshold = EValueCalculator.new(@mesh_freqs.occurrences, @e_value_threshold)
     
    mesh_below_e_threshold.each(&block)
  end
  
  def mesh_freqs_below_e
    @mesh_freqs_below_e ||= grab_mesh_freqs_below_e
  end
  
  private

  def grab_mesh_freqs_below_e
    returning Array.new do |below_e|
      self.each_mesh_freq do |mesh_keyword_id, frequency, e_value|
        below_e << {:mesh_keyword_id => mesh_keyword_id, :frequency => frequency, :e_value => e_value}
      end
    end
  end

  # Find the MeSH terms for the PMIDs
  # that we have stored locally in our DB
  def find_local_mesh_terms
    @pmids_without_mesh_annotations = []
    @mesh_freqs = OccurrenceSummer.new(:id)

    @pmids.each_with_index do |pmid, i|
      mesh_keywords = MeshKeyword.find_all_by_pmid(pmid)
      if mesh_keywords.length > 0
        @mesh_freqs.sum(mesh_keywords - @stop_terms)
      else
        @pmids_without_mesh_annotations << pmid
      end
    end
  end
  
  # Retrieve the MeSH terms for any pmids that aren't already
  # in our local database
  def retrieve_unannotated_pmids
    unless @pmids_without_mesh_annotations.empty?
      missing_mesh_headings = MeshSearch.new.search(@pmids_without_mesh_annotations)

      missing_mesh_headings.each do  |pmid, mesh_headings|
        unless mesh_headings.empty?
          mesh_keywords = MeshKeyword.find_all_by_name(mesh_headings)
          @mesh_freqs.sum(mesh_keywords - @stop_terms)
          PmidsMeshKeyword.bulk_insert(pmid, mesh_keywords)
        end
      end
    end
  end
end