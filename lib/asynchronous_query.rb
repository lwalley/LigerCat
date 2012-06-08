module AsynchronousQuery
  
  STATES = {
    :queued => 0,
    :queued_for_update => 2,
    :searching => 3,
    :processing => 4,
    :cached => 1,
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
  
  def perform_query!
    # Implement this in each included class
    raise "Must Implement perform_query!"
  end
  
  def launch_worker    
    Resque.enqueue(self.class, self.id)
    update_state(:queued)
  end 
  
  def state
    STATES.invert[read_attribute(:state)]
  end
  
  def humanized_state
    state.to_s.humanize
  end
  
  def state=(state_sym)
    raise ArgumentError, "Invalid state #{state_sym}, valid states are #{STATES.keys.inspect}" unless STATES.keys.include? state_sym
    write_attribute(:state, STATES[state_sym])
  end
  
  def update_state(state_sym)
    raise ArgumentError, "Invalid state #{state_sym}, valid states are #{STATES.keys.inspect}" unless STATES.keys.include? state_sym
    RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.class.name} id:#{self.id} Changed state to #{state_sym}")
    update_attribute(:state, state_sym)
  end
    
end