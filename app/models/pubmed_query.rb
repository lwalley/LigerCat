require 'rubygems'
require 'pubmed_search'

class PubmedQuery < AsynchronousQuery 
  
  # Associations
  has_many :pubmed_mesh_frequencies
  has_many :mesh_keywords, :through => :pubmed_mesh_frequencies
  has_many :publication_dates, :as => :query do
    def to_histohash
      returning Hash.new(0) do |histohash|
        find(:all).each{|pub_date| histohash[pub_date.year] = pub_date.publication_count }
      end
    end
  end  
  
  # Validators
  validates_presence_of :query
  
  # Callbacks
  after_create :launch_worker
  
  class << self
    def find_by_query(query)
      find_by_query_key create_query_key(query)
    end
    
    def create_query_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
  end
  
  # full_species_name is a special case introduced by putting ligercat clouds in EoL. In normal use,
  # full_species_name will be nil, and we'll use the query to generate the query key. 
  #
  # See the comment above display_query for a discussion into this vagary.
  def before_create
    self.query_key = self.class.create_query_key(full_species_name || query)
  end

  def perform_query!(&block)
    search = if self.eol?
               LigerEngine::SearchStrategies::EolPubmedSearchStrategy.new
             else
               LigerEngine::SearchStrategies::PubmedSearchStrategy.new
             end
    process = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    engine  = LigerEngine::Engine.new(search,process)
    engine.add_observer(self, :liger_engine_update)

    
    results = engine.run(self.query)

    results.tag_cloud.each do |mesh_frequency|
      self.pubmed_mesh_frequencies.build(mesh_frequency)
    end

    results.histogram.each do |year, publication_count|
      self.publication_dates.build(:year => year, :publication_count => publication_count)
    end
    
    self.num_articles = engine.count

    self.save
  end
  
  # Observer method for LigerEngine
  def liger_engine_update(event_name, *args)
    case event_name
    when :before_search               : self.update_state(:searching)
    when :before_processing           : self.update_state(:processing)
    when :before_tag_cloud_processing : self.update_state(:processing_tag_cloud)
    when :before_histogram_processing : self.update_state(:processing_histogram)
    when :log                         : log_liger_engine("#{args[1]} #{args[0]}")
    end
  end

  # Are we an EoL species query, or a regular old query? 
  def eol?
    not eol_taxa_id.nil?
  end
  
  # This is the verbatim string that gets sent out to PubMed in the Search Strategy. We
  # need this accessor method, because the "Selected Terms" panel and the Publication
  # Histogram both need this information to perform their respective AJAX calls.
  def actual_pubmed_query
    if self.eol?
      LigerEngine::SearchStrategies::EolPubmedSearchStrategy::species_specific_query(query)
    else
      query
    end
  end
  
  
  # When we're dealing with an EoL species, the "query" field and the "full species name"
  # are two different things. The query field contains the binomial, while the full species name
  # contains the binomial (or trinomial) plus authorship.
  # 
  # There can be multiple EoL taxa pages for the same species, due to different authorships.
  # For that reason, we use the full species name with authorship to generate the query_key, to
  # avoid collisions in the case where the binomial is the same but the authorships are different.
  #
  # This alleviates some headaches, but introduces others. One headache that it introduces is the
  # quandary of which to display to the user in the views. This method is used to help the view
  # figure out which to display in the search box. In the case of an EoL species, it displays the full
  # species name with authorship. Otherwise, it displays the normal query.
  #
  # TODO: this query vs. full species name with authorship thing is a bit of a mess. It needs to be rethought
  def display_query
    eol? ? self.full_species_name : self.query
  end
end
