require 'rest_client'

class AsynchronousQuery < ActiveRecord::Base
  #include ActionController::UrlFor
  include Rails.application.routes.url_helpers

  self.abstract_class = true
  after_commit :launch_worker, :on => :create

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

    # Command-patternt type interface called by a Resque worker.
    # This does the leg-work of finding the respective query AR object
    # and calls the perform_query method.
    # Subclasses will need to implement the perform_query! method to their liking
    def perform(query_id, cache_webhook=nil)
      query = self.find(query_id)
      query.update_state(:searching)
      query.perform_query!
      query.update_state(:cached)

      RestClient.delete(cache_webhook) rescue nil
      query.log_liger_engine("Received webhook: #{cache_webhook.inspect}")
    rescue Exception => e
      query.update_state(:error) unless query.blank?
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
  end

  def done?
    [:cached, :queued_for_refresh].include? self.state
  end

  def perform_query!
    # Implement this in each subclass
    raise "Must Implement perform_query!"
  end

  # Called by after_commit :on => :create to put a newly created Query into the queue to be processed
  def launch_worker
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
