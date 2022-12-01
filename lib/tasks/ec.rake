namespace :ec do
  desc "TODO"
  task nm_crawl: :environment do
    NewUserSpider.check_for_new_members = true
  end
end
