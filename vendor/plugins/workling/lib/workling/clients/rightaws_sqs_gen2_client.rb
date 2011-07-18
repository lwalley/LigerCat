require 'base64'
require 'right_aws'
require 'workling/clients/base'


#  Connect from the console:
#    connection = Workling::Clients::RightawsSqsGen2Client.new.connect
#  Show all queues:
#    connection.queues.each { |queue| puts queue.name };nil
#  Clear all queues:
#    connection.queues.each { |queue| queue.clear };nil
#  Delete all queues:
#    connection.queues.each { |queue| queue.delete };nil

module Workling
  module Clients
    class RightawsSqsGen2Client < Workling::Clients::Base

      attr_accessor :connection
      
      def connect
        options = {:multi_thread => true}
        options.merge!(Workling.config[:aws])
        options[:logger] = Workling::Base.logger

        self.connection = RightAws::SqsGen2.new(options.delete('access_key_id'), options.delete('secret_access_key'), options)
        #puts "Workling::Clients::RightawsSqsGen2Client connected"
      end
      
      def close; true; end

      def request(key, value)
        #puts "Workling::Clients::RightawsSqsGen2Client requesting #{key} #{value}"
        data = Base64.encode64(Marshal.dump(value))
        get_queue(key).send_message(data)
        #puts "Workling::Clients::RightawsSqsGen2Client requested #{key} #{value}"
      end
      
      def retrieve(key, delete_queue = false)
        #puts "Workling::Clients::RightawsSqsGen2Client retrieving #{key}"
        queue = get_queue(key)
        #puts "Workling::Clients::RightawsSqsGen2Client retrieving #{key} - getting message"
        message = queue.receive
        out = nil
        unless message.nil?
          #puts "Workling::Clients::RightawsSqsGen2Client retrieved #{key}"
          out = Marshal.load(Base64.decode64(message.body))
          message.delete
          queue.delete if delete_queue
        end
        return out
      end
            
      private
        def get_queue(key)
          #puts "Workling::Clients::RightawsSqsGen2Client get_queue #{key}"
          self.connection.queue(key)
        end
    end
  end
end