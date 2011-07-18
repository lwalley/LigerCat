class NuccoreQuery < ActiveRecord::Base
  include AsynchronousQuery
  
  has_many :results,         :class_name => 'NuccoreResult', :dependent => :destroy
  has_many :nuccore_results, :dependent  => :destroy
  has_many :sequences,       :through    => :nuccore_results
  
  validates_presence_of :query
  
  after_create :launch_worker
  
  def launch_worker
    logger.info "INFO: Launching a nuccore_worker with job key #{self.job_key}"
    MiddleMan.new_worker(:worker => :nuccore_worker, :job_key => self.job_key)
    MiddleMan.worker(:nuccore_worker, self.job_key).execute_search(self.id)
  end
  
  def perform_query!(&block)
    gi_numbers = NuccoreSearch.new.search(self.query)
    
    logger.info "INFO: Retrieved #{gi_numbers.size} gi numbers from nuccore"
    
    gi_numbers.each_with_index do |gi_number, i|
      sequence = Sequence.find_or_create_by_id(gi_number)
      self.nuccore_results.create({:sequence_id => sequence.id})
      
      yield i, gi_numbers.length if block_given? && i % 100 < 1
      
    end
  end
  
end
