require 'resque'

module Resque
  module Failure
    # Emails failure messages.
    # Note: uses Mail (default in Rails 3.0) not TMail (Rails 2.x).
    class Notifier < Base
      class << self
        attr_accessor :sender, :recipients
        
        def configure
          yield self
        end
      end
      
      def save
        puts "sending failure notificiation to #{self.class.recipients.join(', ')}"
        text, subject = detailed, "[LigerEngine Error] #{queue}: #{exception}"
        sender = self.class.sender
        recipients = self.class.recipients
        Mail.deliver do
          from sender
          to recipients
          subject subject
          text_part do
            body text
          end
        end
      rescue => error
        Rails.logger.error("Irony of Ironies! Exception raised sending Resque failure notification:" +
          "\n==============================\n"+
          error.message + 
          "\n==============================\n"+
          error.inspect +
          "\n==============================\n"+
          error.backtrace.join("\n") rescue error.backtrace.to_s +
          "\n==============================\n")
      end
      
      def detailed
        <<-EOF
#{worker} failed processing #{queue}:

Payload:
#{payload.inspect}

Exception:
#{exception.message}
===
#{exception.inspect}
==
#{exception.backtrace.join("\n") rescue exception.backtrace }
EOF
      end
    end
  end
end