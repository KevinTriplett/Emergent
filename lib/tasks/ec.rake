namespace :ec do
  desc "TODO"
  task nm_crawl: :environment do
    NewMemberSpider.crawl!
  end
end
