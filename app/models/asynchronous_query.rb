require 'after_commit'

class AsynchronousQuery < ActiveRecord::Base
  self.abstract_class = true
  after_commit_on_create :launch_worker

  # Maps the state integer codes stored in the database to programmer-friendly
  # symbols. If you create or rename a new state, please for heaven's sake do 
  # not modify or re-use integer codes. Just come up with a new one. They are
  # meaningless aside from their uniqueness
  STATES = {
    :queued => 0,
    :queued_for_update => 2,
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
      :ligercat
    end
    
    # Command-patternt type interface called by a Resque worker.
    # This does the leg-work of finding the respective query AR object
    # and calls the perform_query method.
    # Subclasses will need to implement the perform_query! method to their liking
    def perform(query_id)
      query = self.find(query_id)
      query.update_state(:searching)
      query.perform_query!
      query.update_state(:cached)
    rescue Exception => e
      query.update_state(:error) unless query.blank?
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
  end

  def done?
    [:cached, :queued_for_update].include? self.state
  end
  
  def perform_query!
    # Implement this in each included class
    raise "Must Implement perform_query!"
  end
  
  # Called by after_commit_on_create to put a newly created Query into the queue to be processed
  def launch_worker    
    Resque.enqueue(self.class, self.id)
    update_state(:queued)
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
    write_attribute(:state, STATES[state_sym])
  end
  
  
  # Updates the state attribute with the correct integer-code, and provides a handy log message of the state change
  def update_state(state_sym)
    raise ArgumentError, "Invalid state #{state_sym}, valid states are #{STATES.keys.inspect}" unless STATES.keys.include? state_sym
    log_liger_engine "Changed state to #{state_sym}"
    update_attribute(:state, state_sym)
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
    when :before_search               : update_state(:searching)
    when :before_processing           : update_state(:processing)
    when :before_tag_cloud_processing : update_state(:processing_tag_cloud)
    when :before_histogram_processing : update_state(:processing_histogram)
    when :log                         : log_liger_engine("#{args[1]} #{args[0]}")
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
    RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.class.name} id:#{self.id} #{msg}")
  end
    
end
