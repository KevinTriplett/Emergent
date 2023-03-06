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
  every 1.day, at: "4:30 am" do
    rake "ec:nm_crawl_all"
  end

  every 1.hour do
    rake "ec:nm_crawl_new"
  end

  every 15.minutes do
    rake "ec:send_survey_invite_messages"
  end
end

every 1.day do
  rake "ec:backup"
end
