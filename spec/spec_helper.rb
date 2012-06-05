# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + "/shared/asynchronous_query_spec")

require 'fakeweb'


Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
end


def fake_esearch_response(search_term, options={})
  file = options[:file] || search_term.gsub(/\W/, '_') + '_esearch.xml'
  FakeWeb.register_uri(:any, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmax=100000&retstart=0&term=#{URI.escape search_term}",
                       :body => File.dirname(__FILE__) + "/mocked_eutils_responses/#{file}")
end


class OnlyInclude
  def initialize(entries)
    @expected_entries = entries
  end
  
  def matches?(array)
    @array = array
    @array.sort == @expected_entries.sort
  end
  
  def description
    "only include"
  end
  
  def failure_message
    if @expected_entries.length != @array.length
      "expected to have #{@expected_entries.length} entries, but had #{@array.length}: #{@array.inspect}"
    else
      "expected #{@array.inspect} to include #{(@expected_entries - @array).inspect}"
    end
  end
  
  def negative_failure_message
    "#{@array.inspect} expected to include other entries"
  end
end

def only_include(*args)
  OnlyInclude.new args
end



def redis_fixture(prefix)
  redis = RedisFactory.gimme(prefix)
  fixture_file = Spec::Runner.configuration.fixture_path + "/#{prefix}.redis"
  File.open(fixture_file) do |redis_commands|
    redis.flushdb
    
    redis_commands.each_line do |line|
      line.chomp!
      redis.client.write(line.split(/\t/)) unless line.empty? or line.starts_with?('#')
    end
  end
end



# == Full Stack Helpers
#
# A collection of helpers for doing full-stack testing, kinda like Merb
#
# This is a hack and needs to be replaced, perhaps with Rackbox
#

def find_controller_name(method, path)
   ActionController::Routing::Routes.recognize_path(path, :method => method)[:controller]
end

def find_controller_class_name(method, path)
  (find_controller_name(method, path) + "_controller").camelize
end

def do_get (url, format=:html)   do_request(:get,    url, format); end
def do_post(url, format=:html)   do_request(:post,   url, format); end
def do_put (url, format=:html)   do_request(:put,    url, format); end
def do_delete(url, format=:html) do_request(:delete, url, format); end
def do_head(url)                 do_request(:head,   url);         end

def do_request(method, url, format=:html)
  params = params_from(method, url)
  action = action_from(method, url)
  params.delete :controller
  params.delete :action
  params[:format] = format.to_s
  
  @request.env['REQUEST_METHOD'] = method.to_s.upcase
  process action, params
end

def do_xhr(method, url)
  params = params_from(method, url)
  action = params[:action]
  params.delete :controller
  params.delete :action
  
  xhr method, action, params
end

def action_from(method, url)
  params_from(method, url)[:action]
end
