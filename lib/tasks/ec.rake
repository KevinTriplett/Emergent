namespace :ec do
  desc "TODO"
  task crawl: :environment do
    WebSpider.crawl!
  end
end
