class PubmedQuery < Query
  # Validators
  validates_presence_of :query

  def search_strategy
    @search_strategy ||= LigerEngine::SearchStrategies::PubmedSearchStrategy.new
  end

  def slug
    query[0,100].parameterize
  end
  
  def query
    read_attribute(:query)
  end

  # This is the verbatim string that gets sent out to PubMed in the Search Strategy. We
  # need this accessor method, because the "Selected Terms" panel and the Publication
  # Histogram both need this information to perform their respective AJAX calls.
  def actual_pubmed_query
    query
  end

end
