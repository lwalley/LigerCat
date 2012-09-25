desc "Enqueues the oldest cached queries so they can be refreshed. This should be called from a cronjon, see schedule.rb"
task :enqueue_oldest_cached_queries, [:num_queries] => :environment do |t, args|
  num_queries = args.num_queries.to_i
    
  if Resque.size(Query.refresh_queue) == 0
    Rails.logger.info "#{Time.now} Queue is empty, checking for candidates"
    
    Query.enqueue_refresh_candidates(num_queries)
  else
    Rails.logger.info "#{Time.now} There are already items in the #{Query.refresh_queue} queue, skipping."
  end

end