module AsynchronousQuery
  
  STATES = {
    :queued => 1,
    :queued_for_update => 2,
    :searching => 3,
    :processing => 4,
    :cached => 5,
    :error => 6
  }
  
  def self.included includer    
    includer.extend ClassMethods  
  end
  
  
  module ClassMethods
    def queue
      :ligercat
    end
    
    def perform(query_id)
      query = self.find(query_id)
      query.update_state(:searching)
      query.perform_query!
      query.update_state(:cached)
    rescue Exception => e
      query.update_state(:error)
      
      # TODO: make an error flag in the database to alert user to an error
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
  end

  def done?
    [:cached, :queued_for_update].include? self.state
  end
  
  # TODO: Probably don't need this with Resque
  def job_key
    "#{self.class.name}-#{self.id}"
  end
  
  def perform_query!
    # Implement this in each included class
    raise "Must Implement perform_query!"
  end
  
  def launch_worker
    RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.class.name} id:#{self.id} Adding query to the queue")
    
    Resque.enqueue(self.class, self.id)
    update_state(:queued)
  end 
  
  def state
    STATES.reverse[read_attribute(:state)]
  end
  
  def state=(state_sym)
    raise AttributeError unless STATES.keys.include? state_sym
    write_attribute(:state, STATES[state_sym])
  end
  
  def update_state(state_sym)
    raise AttributeError unless STATES.keys.include? state_sym
    RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.class.name} id:#{self.id} Changed state to #{state_sym}")
    update_attribute(:state, STATES[state_sym])
  end
    
end