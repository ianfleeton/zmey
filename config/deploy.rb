require "bundler/capistrano"

require "rvm/capistrano"
set :rvm_type, :system
set :rvm_path, "/usr/local/rvm"

set :application, "zmey"
raise 'Set the ZMEY_REPOSITORY environment variable before deploying' unless ENV['ZMEY_REPOSITORY']
set :repository,  ENV['ZMEY_REPOSITORY']
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/admin/railsapps/#{application}"

server 'io.yesl.co.uk', :app, :web, :db, primary: true
server 'straylight.yesl.co.uk', :app, :web, :db, primary: true
set :user, 'admin'
default_run_options[:pty] = true

set :keep_releases, 5

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Symlinks files with secret information and extras"
  task :symlink_secrets_and_extras, roles: :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{deploy_to}/shared/config/secrets.yml #{release_path}/config/secrets.yml"
  end
end

before 'deploy:assets:precompile', 'deploy:symlink_secrets_and_extras'

after 'deploy:update_code', 'deploy:migrate'

ssh_options[:forward_agent] = true

set :shared_children, shared_children + %w{public/invoices public/up}
