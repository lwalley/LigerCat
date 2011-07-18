require 'workling/return/store/base'
require 'workling/clients/memcache_queue_client'

#
#  Recommended Return Store if you are using the Starling Runner. This
#  Simply sets and gets values against queues. 'key' is the name of the respective Queue. 
#
module Workling
  module Return
    module Store
      class RightawsSqsGen2ReturnStore < Base
        cattr_accessor :client
        
        def initialize
          self.client = Workling::Clients::RightawsSqsGen2Client.new
          self.client.connect
        end
        
        # set a value in the queue 'key'. 
        def set(key, value)
          #puts "Workling::Return::Store::RightawsSqsGen2ReturnStore setting #{key} #{value.inspect}"
          self.class.client.request(key, value)
        end
        
        # get a value from AWS queue 'key'.
        def get(key)
          #puts "Workling::Return::Store::RightawsSqsGen2ReturnStore getting #{key}"
          self.class.client.retrieve(key, true)
        end
      end
    end
  end
end