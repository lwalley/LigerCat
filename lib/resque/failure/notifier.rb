require 'resque'

module Resque
  module Failure
    # Emails failure messages.
    # Note: uses Mail (default in Rails 3.0) not TMail (Rails 2.x).
    class Notifier < Base      
      def save
        Feedback.resque_failure(worker, queue, payload, exception).deliver
      rescue => error
        Rails.logger.error("Irony of Ironies! Exception raised sending Resque failure notification:" +
          "\n==============================\n"+
          error.message + 
          "\n==============================\n"+
          error.inspect +
          "\n==============================\n"+
          (error.backtrace.join("\n") rescue error.backtrace.to_s) +
          "\n==============================\n")
      end
    end
  end
end