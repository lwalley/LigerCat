class PubmedMeshFrequency < KeywordFrequency
  belongs_to :pubmed_query
  belongs_to :mesh_keyword

  attr_accessible :pubmed_query_id

  def score
    @score ||= mesh_keyword.score
  end

  def name
    @name ||= mesh_keyword.name
  end
end
