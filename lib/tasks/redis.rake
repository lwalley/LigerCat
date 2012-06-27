require 'redis'

namespace :redis do 
  desc 'Load the seed data from db/seeds_redis.rb into Redis'
  task :seed => :environment do
    seed_file = File.join(Rails.root, 'db', 'seeds_redis.rb')
    load(seed_file) if File.exist?(seed_file)
  end
  
end