require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + "/../shared/keyword_frequency_spec")

describe BlastMeshFrequency do
  fixtures :blast_mesh_frequencies, :mesh_keywords, :blast_queries

  it_should_behave_like 'A KeywordFrequency'

  before(:each) do
    @freq = BlastMeshFrequency.create({:mesh_keyword_id => mesh_keywords(:animals).id,
                                       :blast_query_id => blast_queries(:amino_acid_query).id,
                                       :frequency => 2})
  end

end
