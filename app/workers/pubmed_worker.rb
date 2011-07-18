class PubmedWorker < Workling::Base
  def execute_search(options)
    # Find the PubmedQuery object in question
    pumbed_query = nil
    begin
      pubmed_query = PubmedQuery.find(options[:id])
    rescue ActiveRecord::RecordNotFound => e
      sleep(3)
      pubmed_query = PubmedQuery.find(options[:id])
    end
    
    # Perform a search
    begin
      time_start = Time.now
      pubmed_query.perform_query!
      pubmed_query.update_attribute(:done, true)
      time_end   = Time.now
      
      # PubMed requires at least 0.3 seconds between requests. We're gonna do 1 just to be on the safe side.
      sleep 1.0 - (time_end - time_start) if (time_end - time_start) < 1.0
    rescue Exception => e
      pubmed_query.launch_worker if pubmed_query.respond_to?(:launch_worker)
      logger.error("PubmedWorker#execute_search for the query '#{pubmed_query.query}': " + e.to_s)
      ExceptionNotifier.deliver_custom_notification("PubmedWorker#execute_search for the query '#{pubmed_query.query}'", e)
    end
  end
end
