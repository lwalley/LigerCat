module AsynchronousQuery
  def done?
    read_attribute(:done)
  end
  
  def job_key
    "#{self.class.name}-#{self.id}"
  end
  
  def perform_query!
    # Implement this in each included class
    raise "Must Implement perform_query!"
  end
  
  def launch_worker
    raise "Must Implement launch_worker"
  end
end