module AsynchronousQuery  
  
  def self.included includer    
    includer.extend ClassMethods
  end
  
  
  module ClassMethods
    def queue
      :ligercat
    end
    
    def perform(query_id)
      query = self.find(query_id)
      RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.name} id:#{query_id} about to begin processing")
      query.perform_query!
      query.update_attribute(:done, true)
      RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.name} id:#{query_id} finished processing")
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.info("LigerEngine: #{self.name} id:#{query_id} Errored: #{e.message}")
      
      # TODO: make an error flag in the database to alert user to an error
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
  end

  def done?
    read_attribute(:done)
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
  end
end