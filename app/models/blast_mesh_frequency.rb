class BlastMeshFrequency <  KeywordFrequency
  belongs_to :blast_query
  belongs_to :mesh_keyword

  def score
    @score ||= mesh_keyword.genbank_score
  end

  def name
    @name ||= mesh_keyword.name
  end
end
