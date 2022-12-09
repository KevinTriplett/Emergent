namespace :ec do
  desc "TODO"
  task nm_crawl: :environment do
    NewUserSpider.crawl!
  end

  task import_users: :environment do
    User.import_users
  end
end
