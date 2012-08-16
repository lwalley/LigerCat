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
      rescue
        puts "Error sending mail: " + $!
      end
      
      def detailed
        <<-EOF
#{worker} failed processing #{queue}:
Payload:
#{payload.inspect.split("\n").map { |l| "  " + l }.join("\n")}
Exception:
  #{exception}
#{exception.backtrace.map { |l| "  " + l }.join("\n")}
        EOF
      end
    end
  end
end