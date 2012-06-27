# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require "bundler/setup"

PRIVATE_CONFIG = YAML.load_file(RAILS_ROOT + '/config/private.yml')


Rails::Initializer.run do |config|

  config.action_controller.session = {
    :key    => PRIVATE_CONFIG['session_key'],
    :secret => PRIVATE_CONFIG['session_secret']
  }

end

Mime::Type.register_alias "text/html", :cloud

AsynchronousQuery.default_url_options[:host] = PRIVATE_CONFIG['host']

# Email list for ExceptionNotifier  
ExceptionNotifier.exception_recipients = PRIVATE_CONFIG['exception_recipients']

ExceptionNotifier.sender_address = PRIVATE_CONFIG['no_reply_address']

FEEDBACK_RECIPIENTS = PRIVATE_CONFIG['feedback_recipients']

ActionMailer::Base.delivery_method = :sendmail

ENV['RECAPTCHA_PUBLIC_KEY']  = PRIVATE_CONFIG['recaptcha_public_key']
ENV['RECAPTCHA_PRIVATE_KEY'] = PRIVATE_CONFIG['recaptcha_private_key']

# EUtils configuration
require 'bio'
Bio::NCBI.default_email = PRIVATE_CONFIG['eutils_email']
LigerEngine::SearchStrategies::PubmedSearchStrategy.email = PRIVATE_CONFIG['eutils_email']
LigerEngine::SearchStrategies::PubmedSearchStrategy.tool = PRIVATE_CONFIG['eutils_tool']
LigerEngine::PubmedFetcher.email = PRIVATE_CONFIG['eutils_email']
LigerEngine::PubmedFetcher.tool = PRIVATE_CONFIG['eutils_tool']

# Require some gems after Rails::Initializer so that they bootstrap properly
require 'will_paginate'
