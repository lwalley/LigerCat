module LigerEngine
  class Engine
    attr_accessor :search_strategy
    attr_accessor :processing_strategy
    attr_accessor :article_count
  
    def initialize(search_strategy, processing_strategy)
      raise ArgumentError, "Search Strategy must respond to :search" unless search_strategy.respond_to? :search
      raise ArgumentError, "Processing Strategy must respond to :process" unless processing_strategy.respond_to? :process
    
      @search_strategy = search_strategy
      @processing_strategy = processing_strategy
    end
  
    def run(query)
      pmid_list = @search_strategy.search(query)
      results = @processing_strategy.process(pmid_list)
      
      @article_count = pmid_list.length
      
      results
    end
  end
end
