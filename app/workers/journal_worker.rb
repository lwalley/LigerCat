class JournalWorker < Workling::Base
  def execute_search(options)
    # Find the NuccoreQuery object in question
    journal_query = nil
    begin
      journal_query = JournalQuery.find(options[:id])
    rescue 
      sleep(3)
      journal_query = JournalQuery.find(options[:id])
    end
    
    # Perform a search
    begin
      journal_query.perform_query!
      journal_query.update_attribute(:done, true)
    rescue Exception => e
      ExceptionNotifier.deliver_custom_notification("JournalWorker#execute_search for the query '#{journal_query.query}'", e)
    end
  end
end

