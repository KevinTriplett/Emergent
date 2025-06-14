# config valid for current version and patch releases of Capistrano
lock "~> 3.19.0"

set :application, "Emergent"
set :repo_url, "git@github.com:KevinTriplett/Emergent.git"
set :deploy_to, "/home/deploy/#{fetch :application}/#{fetch :stage}/"

# ref https://stackoverflow.com/questions/72918950/error-when-uploading-ruby-on-rails-application-with-capistrano
set :passenger_environment_variables, {
  'PASSENGER_INSTANCE_REGISTRY_DIR' => '/tmp'
}

# Default deploy_to directory is /var/www/my_app_name
set :rbenv_prefix, '/usr/bin/rbenv exec' # Cf issue: https://github.com/capistrano/rbenv/issues/96

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :bundle_jobs, 2