class PubmedMeshFrequency < KeywordFrequency
  belongs_to :pubmed_query
  belongs_to :mesh_keyword

  attr_accessible :mesh_keyword_id, :pubmed_query_id, :frequency

  def score
    @score ||= mesh_keyword.score
  end

  def name
    @name ||= mesh_keyword.name
  end
end
