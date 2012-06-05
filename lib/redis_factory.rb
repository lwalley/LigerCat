require 'redis'
require 'redis/distributed'
require 'yaml'

# This class is for managing Redis database configurations
# using config/redis.yml. 
#
# If multiple hosts are defined, it will generate you a DistRedis,
# otherwise you get a Redis object, both defined in the redis-rb rubygem

class RedisFactory
  cattr_accessor :configurations
  
  class << self
    def gimme(prefix='')
      config = current_config(prefix)
      
      if config[:hosts].is_a? Array
        
        # TODO: loop through hosts array, passing each host and the database id to a build-url method, instantiate Redis::Distributed with those options
        
        host_urls = config[:hosts].map{|host| build_uri(host, config[:database]) }
        
        Redis::Distributed.new(host_urls)
      else
        Redis.new(config)
      end
    end
    
    def current_config(prefix)
      prefix = prefix.to_s
      
      config_key = if prefix.empty?
                    Rails.env
                  else
                    prefix.chomp('_') + '_' + Rails.env
                  end
      
      config = configurations[config_key]
      
      if config
        config.symbolize_keys!
      else
        raise "Could not find a Redis configuration for '#{config_key}', please doublecheck config/redis.yml"
      end
     
      config[:db] ||= config[:database]
     
      config
    end
    
    def configurations
      @@configurations ||= YAML.load_file(RAILS_ROOT + '/config/redis.yml')
    end
    
    def build_uri(host_port, database)
      "redis://#{host_port}/#{database}"
    end
    
  end
end