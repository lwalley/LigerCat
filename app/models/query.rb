require 'rest_client'

# This is a base class for all the other types of Queries. 
# You should never create a base Query, but it is sometimes helpful to find all Queries
class Query < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  # Callbacks
  before_save :enforce_abstract_class
  before_create :set_key
  after_commit :enqueue, :on => :create
  
  # Associations  
  has_many :mesh_frequencies, :dependent => :delete_all
  has_many :mesh_keywords, :through => :mesh_frequencies
  has_many :publication_dates, :dependent => :delete_all do
    def to_histohash
      Hash.new(0).tap do |histohash|
        self.all.each{|pub_date| histohash[pub_date.year] = pub_date.publication_count }
      end
    end
  end 
  
  attr_accessible :state, :query, :type

  # Maps the state integer codes stored in the database to programmer-friendly
  # symbols. If you create or rename a new state, please for heaven's sake do 
  # not modify or re-use integer codes. Just come up with a new one. They are
  # meaningless aside from their uniqueness
  STATES = {
    :queued => 0,
    :queued_for_refresh => 2,
    :searching => 3,
    :processing => 4,
    :cached => 1,
    :error => 6,
    :processing_tag_cloud => 7,
    :processing_histogram => 8
  }
  
  scope :failed, where(:state => STATES[:error])
  

  class << self
    # Sets the queue that Resque should use
    def queue
      :new_queries
    end

    def refresh_queue
      :refresh_cached_queries
    end
    
    def find_refresh_candidates(limit=1000)
      self.where("state=? AND updated_at<?", STATES[:cached], 1.week.ago).order('updated_at ASC').limit(limit).all
    end

    def enqueue_refresh_candidates(limit = 1000)
      candidates = find_refresh_candidates(limit)

      logger.info( candidates.empty? ? "#{Time.now} No #{self.name.pluralize} are candidates for refresh. Skipping" : "#{Time.now} Enqueing #{candidates.length} #{self.name.pluralize}" )

      candidates.each{|c| c.enqueue_for_refresh }
    end
    
    def find_or_create_by_query(query, model_subclass)
      find_by_query(query) || model_subclass.create(:query => query)
    end

    # The query string could possibly be very long. It's unfeasible to index such a long field,
    # so we create a MD5 hash of the query, called key, and store it in an indexed field.
    #
    # When users type a query into the search box, we want to expeditiously see if that query exists
    # in the database, so this method provides a seamless interface to do that, hiding the key
    # thing from the PubmedQuery API.
    def find_by_query(query)
      find_by_key create_key(query)
    end
    
    def create_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
    

    # Command-pattern type interface called by a Resque worker.
    # This does the leg-work of finding the respective query AR object
    # and calls the perform_query method.
    # Subclasses will need to implement the perform_query! method to their liking
    def perform(query_id, cache_webhook=nil)
      query = self.find(query_id)
      query.update_state(:searching)
      query.perform_query!
      query.update_state(:cached)

      RestClient.delete(cache_webhook) rescue nil
      query.log_liger_engine("Hit webhook: #{cache_webhook.inspect}")
    rescue Exception => e
      query.update_state(:error) unless query.blank?
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
  end
  
  # This method is called by #perform. It is responsible for instantiating a new 
  # LigerEngine, taking the results and building mesh_frequencies and publication_dates.
  #
  # Subclasses must define a method called #search_strategy that returns a new instance
  # of their desired search strategy for the Engine.
  #
  # Subclasses must define a method called #query that will return the input sent to the
  # search strategy
  def perform_query!
    search  = self.search_strategy
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

    self.save!
  end

  def enforce_abstract_class
    raise "Query is an abstract class, you should not instantiate one." if self.class.name == 'Query'
  end
  
  def query
    raise "You must define #query in your subclass"
  end
  
  def set_key
    self.key = self.class.create_key(query)
  end
  
  
  # This method should return a new instance of a LigerEngine::SearchStrategy
  def search_strategy
    raise "You must implement #search_strategy in your subclass"
  end

  def done?
    [:cached, :queued_for_refresh].include? self.state
  end
  
  def error?
    self.state == :error
  end

  # Called by after_commit :on => :create to put a newly created Query into the queue to be processed
  def enqueue
    Resque.enqueue(self.class, self.id)
    update_state(:queued)
  end

  def enqueue_for_refresh
    Resque.enqueue_to(self.class.refresh_queue, self.class, self.id, cache_webhook_uri)
    update_state(:queued_for_refresh)
  end

  # The HTML pages for these queries are page-cached on the webserver.
  # After a worker is finished refreshing a Query's tag cloud and histogram,
  # it needs to inform the webserver to delete the page cache.
  #
  # This is done with a webhook whose uri is passed to the worker as a parameter.
  # This uri is generated in this method, which is kind of non-MVC, so we quarrantine 
  # it in its own method.
  def cache_webhook_uri
    url_for(:controller => self.class.name.underscore.pluralize,
            :action     => :cache,
            :id         => self.id)
  end

  # Returns the symbol version of the state integer code stored in the database
  def state
    STATES.invert[read_attribute(:state)]
  end

  # Provides a user-friendly version of the current state for use in views. Can (and should?) be overridden in subclasses
  def humanized_state
    state.to_s.humanize
  end

  # Accepts the symbol version of our states, and writes the corresponding integer code to the database
  def state=(state_sym)
    raise ArgumentError, "Invalid state #{state_sym}, valid states are #{STATES.keys.inspect}" unless STATES.keys.include? state_sym
    update_column(:state, STATES[state_sym])
  end

  # This wraps #state= with a log message
  def update_state(state_sym)
    self.state = state_sym
    log_liger_engine "Changed state to #{state_sym}"
  end

  # This method handles notifications from LigerEngine and handles them appropriately.
  # Sub-classes can optionally override this to add more behavior if they wish.
  #
  # Make absolutely sure that when you create a new LigerEngine in your subclass's
  # #perform_query! method, that you add this method as an observer to the LigerEngine,
  # like so:
  #       engine  = LigerEngine::Engine.new(search,process)
  #       engine.add_observer(self, :liger_engine_update)
  #
  def liger_engine_update(event_name, *args)
    case event_name
    when :before_search               then update_state(:searching)
    when :before_processing           then update_state(:processing)
    when :before_tag_cloud_processing then update_state(:processing_tag_cloud)
    when :before_histogram_processing then update_state(:processing_histogram)
    when :log                         then log_liger_engine("#{args[1]} #{args[0]}")
    end
  end

  # Provides a common logging header for LigerEngine messages.
  # Because LigerEngine can (and should) be run with multiple workers, the log messages of
  # simultaneously-running workers will be interspersed with each other. This method
  # provides a header to allow all the log messages from a single Query to be easily searched
  #
  # For example, the log messages from a PubmedQuery#id-12 would look like:
  #    LigerEngine: PubmedQuery id:12 Changed state to cached
  def log_liger_engine(msg)
    Rails.logger.info("#{Time.now} LigerEngine: #{self.class.name} id:#{self.id} #{msg}")
  end

end
