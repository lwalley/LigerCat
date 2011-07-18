require 'workling/clients/base'
require 'active_support/core_ext/hash/keys' # for Hash#symbolize_keys!

module Workling
  module Clients
    class SyncAmqpClient < Workling::Clients::Base

      cattr_accessor :client_class # This is the actual adapter, such as the Bunny or Carrot gems
      attr_accessor :connection

      cattr_accessor :workling_config # a symbolized version of the config yaml

      attr_accessor :queue_defaults
      attr_accessor :message_defaults


      def initialize(client_type = nil, options = {})
        client_type ||= :client
        client_type = client_type.to_sym if client_type.respond_to?(:to_sym)

        self.queue_defaults, self.message_defaults = *self.class.get_config(client_type, :queue_options, :message_options)

        self.queue_defaults.merge!(options) if options
      end
      
      def connect
        @queueserver_urls = Workling.config[:listens_on].split(',').map { |url| url ? url.strip : url }
        host, port = *@queueserver_urls.first.split(':')

        options = {:host => host, :port => port.to_i}
        options.merge!(Workling.config[:amqp_options].symbolize_keys) if Workling.config[:amqp_options]

        # Workling::Base.logger.debug{ "Workling::Clients::SyncAmqpClient starting using #{client_class}" }

        begin
          self.connection = self.class.client_class.new(options) #(:logging => true)
          self.connection.start if self.connection.respond_to?(:start) # required by Bunny
        rescue Exception => e
          raise Workling::WorklingConnectionError.new("#{e.class.to_s} - #{e.message}")
        end
      end
      alias_method :reconnect, :connect
      
      def close
        self.connection.stop
      end

      def request(key, value, options = {})
        params = self.message_defaults.merge(options)
        # Workling::Base.logger.debug{ "Workling::Clients::SyncAmqpClient request params : #{params.inspect}" }
        retry_on_exception do
          data = Marshal.dump(value)
          queue = get_queue(key)
          queue.publish(data, params)
        end
      end

      def retrieve(key)
        retry_on_exception do
          queue = get_queue(key)
          return nil unless queue
          data = queue.pop(:ack => true)[:payload] # RMS fixed this bug
          out = nil
          if !data.nil? && data != :queue_empty
            out = Marshal.load(data)
            queue.ack
          end
          out
        end
      end

      def retry_on_exception(&blk)
        begin
          yield
        rescue StandardError => se # All Carrot and Bunny exceptions inherit from StandardError, anything else is beyond our control
          Workling::Base.logger.warn{ "Workling::Clients::SyncAmqpClient StandardError : #{se.message}" }
          self.reconnect
          yield
        end
      end
      protected :retry_on_exception

      def get_queue(key, options = {})
        params = self.queue_defaults.merge(options)
        # Workling::Base.logger.debug{ "Workling::Clients::SyncAmqpClient get_queue params : #{params.inspect}" }
        self.connection.queue(key, params)
      end
      protected :get_queue


      class << self
        def prepare_workling_config
          sync_amqp_options = Workling.config[:sync_amqp_options] || {}
          recurse_symbolize_keys!(sync_amqp_options)
        end
        protected :prepare_workling_config

        def recurse_symbolize_keys!(hash)
          hash.symbolize_keys!
          hash.values.each do |value|
            recurse_symbolize_keys!(value) if value.is_a?(Hash)
          end
          hash
        end
        protected :recurse_symbolize_keys!

        def get_config(client_type, *args)
          @@workling_config ||= self.prepare_workling_config

          options = self.workling_config[client_type] || {}
          args.collect do |arg|
            if this = options[arg]
              this
            else
              {}
            end
          end
        end
      end

    end
  end
end