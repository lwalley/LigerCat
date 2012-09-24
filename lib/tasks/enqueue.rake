desc "Enqueues the oldest cached queries so they can be refreshed. This should be called from a cronjon, see schedule.rb"
task :enqueue_oldest_cached_queries => :environment do
  
  if Resque.size(Query.refresh_queue) == 0
    Rails.logger.info "#{Time.now} Queue is empty, checking for candidates"
    
    Query.enqueue_refresh_candidates
  else
    Rails.logger.info "#{Time.now} There are already items in the #{Query.refresh_queue} queue, skipping."
  end

end