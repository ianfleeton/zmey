# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

app = 'zmey'
set :application, app
raise 'Set the ZMEY_REPOSITORY environment variable before deploying' unless ENV['ZMEY_REPOSITORY']
set :repo_url, ENV['ZMEY_REPOSITORY']

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['ZMEY_BRANCH'] || 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/admin/railsapps/#{app}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :rvm_type, :user
set :rvm_path, '/home/admin/.rvm'

set :ssh_options, {
  forward_agent: true
}

# Passenger
# Thanks to http://blog.manzhikov.com/new-passenger-restart-in-5-version
set :rvm_map_bins, fetch(:rvm_map_bins, []).push('rvmsudo')
set :passenger_restart_command, 'rvmsudo passenger-config restart-app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/newrelic.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/invoices', 'public/system', 'public/up')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :restart_sidekiq do
    on roles(:all) do
      execute :sudo, :systemctl, "restart", "sidekiq"
    end
  end
end

after "deploy", "deploy:restart_sidekiq"
