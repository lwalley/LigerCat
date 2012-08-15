require 'pubmed_search'

class BinomialQuery < PubmedQuery
  # Validators
  validates_presence_of :query

  def set_key
    self.key = self.class.create_key(query)
  end

  def perform_query!(&block)
    search = LigerEngine::SearchStrategies::BinomialPubmedSearchStrategy.new
    process = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    engine  = LigerEngine::Engine.new(search,process)
    engine.add_observer(self, :liger_engine_update)

    results = engine.run(self.query)

    self.mesh_frequencies.clear
    results.tag_cloud.each do |mesh_frequency|
      self.mesh_frequencies.build(mesh_frequency)
    end

    self.publication_dates.clear
    results.histogram.each do |year, publication_count|
      self.publication_dates.build(:year => year, :publication_count => publication_count)
    end

    self.num_articles = engine.count

    self.save
  end

  # TODO Remove this from views, replace with @query.is_a? BinomialQuery, and remove this method
  # Are we an EoL species query, or a regular old query? 
  def eol?
    true
  end

  # This is the verbatim string that gets sent out to PubMed in the Search Strategy. We
  # need this accessor method, because the "Selected Terms" panel and the Publication
  # Histogram both need this information to perform their respective AJAX calls.
  def actual_pubmed_query
    LigerEngine::SearchStrategies::BinomialPubmedSearchStrategy::species_specific_query(query)
  end

  # When we're dealing with an EoL species, the "query" field and the "full species name"
  # are two different things. The query field contains the binomial, while the full species name
  # contains the binomial (or trinomial) plus authorship.
  # 
  # There can be multiple EoL taxa pages for the same species, due to different authorships.
  # For that reason, we use the full species name with authorship to generate the key, to
  # avoid collisions in the case where the binomial is the same but the authorships are different.
  #
  # This alleviates some headaches, but introduces others. One headache that it introduces is the
  # quandary of which to display to the user in the views. This method is used to help the view
  # figure out which to display in the search box. In the case of an EoL species, it displays the full
  # species name with authorship. Otherwise, it displays the normal query.
  #
  # TODO: this query vs. full species name with authorship thing is a bit of a mess. It needs to be rethought
  def display_query
    self.query
  end
  
  # TODO make this expire both the /articles and /eol cache
  def cache_webhook_uri
    url_for(:controller => 'pubmed_queries',
            :action     => :cache,
            :id         => self.id)
  end
  
end
