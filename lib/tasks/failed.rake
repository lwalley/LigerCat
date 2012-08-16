namespace :failed do
  desc "Compares the failed Queries in the database to redis:failures, and retries any that may have been orphaned"
  task :enqueue_orphans => :environment do
    
    batch_size = 1000
    
    all_ids_in_resque = []
    
    (0..Resque::Failure.count).step(batch_size) do |offset|
      in_resque = Resque::Failure.all(offset, batch_size)
      all_ids_in_resque << in_resque.map{|f| f["payload"]["args"][0] }
    end
    
    all_ids_in_resque = all_ids_in_resque.flatten.uniq
    
    Query.failed.find_each do |query|
      query.enqueue unless all_ids_in_resque.include? query.id
    end
    
  end
end