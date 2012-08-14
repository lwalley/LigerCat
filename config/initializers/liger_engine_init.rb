require 'liger_engine/engine'

Query.default_url_options[:host] = Ligercat::Application.config.secret_stuff['host']
LigerEngine::SearchStrategies::PubmedSearchStrategy.email = Ligercat::Application.config.secret_stuff['eutils_email']
LigerEngine::SearchStrategies::PubmedSearchStrategy.tool = Ligercat::Application.config.secret_stuff['eutils_tool']
LigerEngine::PubmedFetcher.email = Ligercat::Application.config.secret_stuff['eutils_email']
LigerEngine::PubmedFetcher.tool = Ligercat::Application.config.secret_stuff['eutils_tool']

