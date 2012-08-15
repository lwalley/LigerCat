require 'spec_helper'
require 'shared/keyword_frequency'

describe BlastMeshFrequency do
  fixtures :mesh_frequencies, :mesh_keywords, :blast_queries

  it_should_behave_like 'A KeywordFrequency'

  before(:each) do
    @freq = BlastMeshFrequency.new
    @freq.mesh_keyword_id = mesh_keywords(:animals).id
    @freq.blast_query_id = blast_queries(:amino_acid_query).id
    @freq.frequency = 2
  end

end
