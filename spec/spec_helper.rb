# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'fakeweb'
require 'redis_factory'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = "random"
end


def fake_esearch_response(search_term, options={})
  file = options[:file] || search_term.gsub(/\W/, '_') + '_esearch.xml'
  FakeWeb.register_uri(:any, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&tool=#{Ligercat::Application.config.secret_stuff['eutils_tool']}&email=#{Ligercat::Application.config.secret_stuff['eutils_email']}&retmax=100000&retstart=0&term=#{URI.escape search_term}",
                       :body => File.dirname(__FILE__) + "/mocked_eutils_responses/#{file}")
end

def redis_fixture(prefix)
  redis = RedisFactory.gimme(prefix)
  fixture_file = RSpec.configuration.fixture_path + "/#{prefix}.redis"
  File.open(fixture_file) do |redis_commands|
    redis.flushdb
    
    redis_commands.each_line do |line|
      line.chomp!
      redis.client.connection.write(line.split(/\t/)) unless line.empty? or line.starts_with?('#')
    end
  end
end

# Helpers for testing page caching
def cached?(path)
  File.exists? ActionController::Base.send(:page_cache_path, path)
end

def clear_cache(path)
  File.delete ActionController::Base.send(:page_cache_path, path) if cached?(path)
end
