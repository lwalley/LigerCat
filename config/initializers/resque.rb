require 'resque'
# The following line allows us to use this initializer outside of Rails, like the resque-web console
require(File.dirname(__FILE__) + '/../../lib/redis_factory') unless Module.const_defined? :RedisFactory



Resque.redis = RedisFactory.gimme('resque')
