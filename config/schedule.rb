# Examples:
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

set :output, "/home/deploy/Emergent/production/current/log/cron.log"

env 'MAILTO', 'output_of_cron@kevintriplett.com'

if 'production' == @environment
  every 5.minutes do
    rake "ec:nm_crawl_new"
    rake "ec:send_survey_invite_messages"
    rake "ec:send_magic_links"
  end
end

every 1.day do
  rake "ec:backup"
end
