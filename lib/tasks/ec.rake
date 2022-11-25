namespace :ec do
  desc "TODO"
  task nm_crawl: :environment do
    NewUserSpider.crawl!
  end
end
