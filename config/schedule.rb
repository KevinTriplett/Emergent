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

set :output, "/home/deploy/Emergent/current/log/cron.log"

if 'production' == @environment
  every 1.day, at: "4:30 am" do
    rake "ec:nm_crawl_all"
  end

  every 1.hour do
    rake "ec:nm_crawl_newest"
  end
end