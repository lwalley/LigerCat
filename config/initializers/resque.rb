require 'resque'
require 'resque/failure/multiple'
require 'resque/failure/redis'

# The following line allows us to use this initializer outside of Rails, like the resque-web console
require(File.dirname(__FILE__) + '/../../lib/redis_factory') unless Module.const_defined? :RedisFactory

Resque.redis = RedisFactory.gimme('resque')

# If we're running as a Rails application, and not from resque-web, then configure the email notifier
if Module.const_defined? :Rails
  require 'resque/failure/notifier'

  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Notifier]
  Resque::Failure.backend = Resque::Failure::Multiple
end