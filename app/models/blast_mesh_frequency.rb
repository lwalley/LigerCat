class BlastMeshFrequency <  KeywordFrequency
  belongs_to :blast_query
  belongs_to :mesh_keyword

  attr_accessible :blast_query_id

  def score
    @score ||= mesh_keyword.genbank_score
  end

  def name
    @name ||= mesh_keyword.name
  end
end
