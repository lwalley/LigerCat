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



# Every half-hour between 5pm and 9am
every '0,30 17-23,0-9 * * *', :roles => [:app]  do
  rake "enqueue_oldest_cached_queries"
end

# TODO Uncomment when ready to test EOL names integration with Patrick
# every :week, :roles => [:app]  do
#   rake "eol:import_archive"
#   rake "eol:write_list"
# end