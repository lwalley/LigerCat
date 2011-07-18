class BlastWorker < Workling::Base
  def execute_search(options)
    # Find the BlastQuery object in question
    blast_query = nil
    begin
      blast_query = BlastQuery.find(options[:id])
    rescue 
      sleep(3)
      blast_query = BlastQuery.find(options[:id])
    end
    
    # Perform a search
    begin
      blast_query.perform_query!
      blast_query.update_attribute(:done, true)
    rescue Exception => e
      ExceptionNotifier.deliver_custom_notification("BlastWorker#execute_search for the BlastQuery-'#{blast_query.id}'", e)
    end
  end
end

