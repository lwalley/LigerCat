module LigerEngine
  class Engine
    include Observable
    
    attr_accessor :search_strategy
    attr_accessor :processing_strategy
    attr_accessor :count
  
    def initialize(search_strategy, processing_strategy)
      raise ArgumentError, "Search Strategy must respond to :search" unless search_strategy.respond_to? :search
      raise ArgumentError, "Processing Strategy must respond to :process" unless processing_strategy.respond_to? :process
    
      @search_strategy = search_strategy
      @processing_strategy = processing_strategy
      
      @search_strategy.add_observer self
      @processing_strategy.add_observer self
    end
  
    def run(query)
          changed; notify_observers :before_search, query
      id_list = @search_strategy.search(query)
          changed; notify_observers :after_search, id_list.length
      @count = id_list.length
      
        changed; notify_observers :before_processing, id_list.length
      results = @processing_strategy.process(id_list)
        changed; notify_observers :after_processing
      
      results
    end
    
    # Forward any notifications from either Strategy on to Engine's observers
    def update(*args)
      changed
      notify_observers *args
    end
    
  end
end
