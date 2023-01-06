namespace :ec do
  desc "Crawls the Emergent Commons MN site for all member requests"
  task nm_crawl_all: :environment do
    Spider.set_message("new_user_spider", "9999")
    NewUserSpider.crawl!
  end
end

namespace :ec do
  desc "Crawls the Emergent Commons MN site only for new member requests"
  task nm_crawl_new: :environment do
    Spider.set_message("new_user_spider", "0")
    NewUserSpider.crawl!
  end
end

namespace :ec do
  desc "Imports users from tmp/import.tsv (a \"tab separated value\" file)"
  task import_users: :environment do
    User.import_users
  end
end

namespace :ec do
  desc "Backup database"
  task backup: :environment do
    yml = YAML.load_file('config/database.yml')[Rails.env]
    `pg_dump -c --no-privileges --no-owner -U #{yml['username']} #{yml['database']} > ~/backups/#{Rails.env}.sql`
  end
end

namespace :ec do
  desc "Restore database"
  task restore: :environment do
    yml = YAML.load_file('config/database.yml')[Rails.env]
    `psql -d #{yml['database']} < ~/backups/#{Rails.env}.sql`
  end
end
