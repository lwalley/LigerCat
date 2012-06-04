# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require "bundler/setup"

Rails::Initializer.run do |config|

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_ligercat_session',
    :secret      => '5b507d24406a825a82c38c3282b93c574aba04d491c0fc610b6e80609ef74074faf4fb3db7112061c42e64275efdd77cdf9dcc8955a970e6e7e093ebfe9bef70'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

Mime::Type.register_alias "text/html", :cloud


# Email list for ExceptionNotifier  
ExceptionNotifier.exception_recipients = %w(recipient1@example.com recipient2@example.com)

# defaults to exception.notifier@default.com
ExceptionNotifier.sender_address = %("Ligercat Error" <errors@example.com>)

ActionMailer::Base.delivery_method = :sendmail

ENV['RECAPTCHA_PUBLIC_KEY']  = '6LfYQwcAAAAAADEL1aBd2qTA1bGJaie9DijCQEPE'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LfYQwcAAAAAAP-wG3o2KdsVrsHpSaB3Frq2HfI6'


# BioRuby configuration
begin
  require 'bio'
  Bio::NCBI.default_email = "recipient@example.com"
rescue Exception => e
  # We require Bio as a gem above, but you can't install the gems with rake gems
  # because of the block of code above. This fixes that. Probably a better way to do this
end

# Workling configuration
begin
  require 'bunny'
  Workling::Clients::SyncAmqpClient.client_class = Bunny
  Workling::Remote.dispatcher = Workling::Remote::Runners::ClientRunner.new
  Workling::Remote.dispatcher.client = Workling::Clients::SyncAmqpClient.new
  Workling::Return::Store.instance = Workling::Return::Store::SyncAmqpReturnStore.new
rescue NameError => e
  # We require Bunny as a gem above, but you can't install the gems with rake gems
  # because of the block of code above. This fixes that. Probably a better way to
  # do this, but whateevrrrr
end

