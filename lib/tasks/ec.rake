namespace :ec do
  desc "Run all cron spiders"
  task run_spiders: :environment do
    Spider.run_spiders
  end
end

namespace :ec do
  desc "Send all queued magic link requests"
  task send_magic_links: :environment do
    Spider.send_magic_links
  end
end

namespace :ec do
  desc "Send all queued survey invites"
  task send_survey_invite_messages: :environment do
    Spider.send_survey_invite_messages
  end
end

namespace :ec do
  desc "Crawls the Emergent Commons MN site for all member requests"
  task nm_crawl_all: :environment do
    Spider.get_new_members(0)
  end
end

namespace :ec do
  desc "Crawls the Emergent Commons MN site only for new member requests"
  task nm_crawl_new: :environment do
    Spider.get_new_members(50)
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
    `pg_dump -c --no-privileges --no-owner -U #{yml['username']} #{yml['database']} > tmp/backups/#{Rails.env}.sql`
  end
end

namespace :ec do
  desc "Restore database"
  task restore: :environment do
    yml = YAML.load_file('config/database.yml')[Rails.env]
    `psql -d #{yml['database']} < tmp/backups/#{Rails.env}.sql`
  end
end

namespace :ec do
  desc "Transfer production database into staging"
  task transfer: :environment do
    Rake::Task["ec:backup"].execute
    `psql -d emergent-staging < tmp/backups/production.sql`
  end
end
