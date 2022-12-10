namespace :ec do
  desc "Crawls the Emergent Commons MN site for pending member requests"
  task nm_crawl: :environment do
    Spider.set_message("new_user_spider", "25") # limits user join requests it crawls
    NewUserSpider.crawl!
  end
end

namespace :ec do
  desc "Imports users from tmp/import.tsv (a \"tab separated value\" file)"
  task import_users: :environment do
    User.import_users
  end
end
