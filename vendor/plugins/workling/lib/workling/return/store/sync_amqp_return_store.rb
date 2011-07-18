require 'workling/return/store/base'
require 'workling/clients/sync_amqp_client'

#
#  Recommended Return Store if you are using the Starling Runner. This
#  Simply sets and gets values against queues. 'key' is the name of the respective Queue. 
#
module Workling
  module Return
    module Store
      class SyncAmqpReturnStore < Base
        cattr_accessor :client

        def initialize
          self.client = Workling::Clients::SyncAmqpClient.new(:returnstore)
          self.client.connect
        end
        
        # set a value in the queue 'key'. 
        def set(key, value, options = {})
          Workling::Base.logger.debug{ "Workling::Return::Store::SyncAmqpReturnStore options : #{options.inspect}" }
          self.class.client.request(key, value, options)
        end
        
        # get a value from queue 'key'.
        def get(key)
          self.class.client.retrieve(key)
        end
      end
    end
  end
end