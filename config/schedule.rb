# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Whenever defaults the RAILS_ENV to production



# Every five minutes between 9pm and 5am on weeknights
# As per NLM's usage guidelines:
# http://www.ncbi.nlm.nih.gov/books/NBK25497/#chapter2.Usage_Guidelines_and_Requiremen

# TODO  uncomment this when EOL crankage is finished
# every '*/5 21-23,0-4 * * 1-5', :roles => [:app]  do
#   rake "enqueue_oldest_cached_queries[10]"
# end

# TODO delete this when EOL crankage is finished
every '*/1 21-23,0-4 * * 1-5', :roles => [:app]  do
  rake "enqueue_oldest_cached_queries[100]"
end

# Every 30 minutes on weekends
# TODO  uncomment this when EOL is cranked
# every '0,30 * * * 0,6', :roles => [:app]  do
#   rake "enqueue_oldest_cached_queries[50]"
# end

# TODO delete when EOL crankage is finished
every '*/1 * * * 0,6', :roles => [:app]  do
  rake "enqueue_oldest_cached_queries[100]"
end

# TODO Uncomment when ready to test EOL names integration with Patrick
# every :week, :roles => [:app]  do
#   rake "eol:import_archive"
#   rake "eol:write_list"
# end