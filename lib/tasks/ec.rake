namespace :ec do
  desc "Send all queued magic link requests"
  task send_magic_links: :environment do
    MagicLinkSpider.crawl! if Spider.message?("magic_link_spider")
  end
end

namespace :ec do
  desc "Send all queued survey invites"
  task send_survey_invite_messages: :environment do
    SurveyInvite.send_messages
  end
end

namespace :ec do
  desc "Crawls the Emergent Commons MN site for all member requests"
  task nm_crawl_all: :environment do
    Spider.set_message("new_user_spider", "0")
    NewMemberSpider.crawl!
  end
end

namespace :ec do
  desc "Crawls the Emergent Commons MN site only for new member requests"
  task nm_crawl_new: :environment do
    success = nil
    for i in 1..10 # limit the loop
      Spider.set_message("new_user_spider", "50")
      NewUserSpider.crawl!
      until success = (Spider.get_result("new_user_spider") == "success")
        sleep i # use the loop index to extend the wait gradually
      end
      break if success
    end
  end
end

namespace :ec do
  desc "Imports users from tmp/import.tsv (a \"tab separated value\" file)"
  task import_users: :environment do
    User.import_users
  end
end

namespace :ec do
  desc "Imports sticky notes from tmp/sticky-import.tsv (a \"tab separated value\" file)"
  task import_stickies_tsv: :environment do
    Survey.import_sticky_notes_tsv
  end
end

namespace :ec do
  desc "Imports sticky notes from tmp/arg.csv (for xxx.csv use 'rake ec:import_stickies_csv fn=xxx')"
  task import_stickies_csv: :environment do
    Survey.import_sticky_notes_csv(ENV["fn"])
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

namespace :ec do
  desc "Transfer production database into staging (backup production first)"
  task transfer: :environment do
    `psql -d emergent-staging < ~/backups/production.sql`
  end
end
