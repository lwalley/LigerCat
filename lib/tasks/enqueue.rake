desc "Enqueues the oldest cached queries so they can be refreshed. This should be called from a cronjon, see schedule.rb"
task :enqueue_oldest_cached_queries => :environment do
  
  if Resque.size(AsynchronousQuery.refresh_queue) == 0
    RAILS_DEFAULT_LOGGER.info "#{Time.now} Queue is empty, checking for candidates"
    
    PubmedQuery.enqueue_refresh_candidates
    BlastQuery.enqueue_refresh_candidates
  else
    RAILS_DEFAULT_LOGGER.info "#{Time.now} There are already items in the #{AsynchronousQuery.refresh_queue} queue, skipping."
  end

end