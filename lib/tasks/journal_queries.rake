namespace :journal_queries do
  desc("Performs journal queries for all subject terms")
  task(:precompute => :environment) do
    allow_skipped_callbacks_on(JournalQuery)
    SubjectTerm.find(:all).each do |term|
      puts term.name
      JournalQuery.without_callback(:launch_worker) do                  # Skip the after_create callback
        query = JournalQuery.create(:query => term.name, :done => true) # an after_create callback would normally be fired here,
        query.perform_query!                                            # this is normally performed by the backgroundrb worker, after being forked
        sleep(3)                                                        # delay for 3 seconds to keep NLM happy
      end
    end
  end
  
  desc("Deletes all JournalQueries and JournalResults")
  task(:delete_all => :environment) do
    JournalResult.delete_all
    JournalQuery.delete_all
  end
end

def allow_skipped_callbacks_on(model)
  model.class_eval do 
    def self.without_callback(method_name, &block)
      raise "#{self.name}##{method_name} doesn't exist, Hosehead" unless method_defined?(method_name)
      original_callback = instance_method(method_name)
      remove_method(method_name)
      define_method(method_name){ true }
      begin
        yield
      ensure
        remove_method(method_name)
        define_method(method_name, original_callback)
      end
    end
  end
end