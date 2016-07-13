require 'capistrano-scm-copy'

# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'my_app_name'
set :scm, :copy
set :copy_local_tar, "/usr/local/bin/gtar" if `uname` =~ /Darwin/

set :user, "parti"
set :stages, ["staging", "production"]
set :default_stage, "staging"
set :deploy_via, :copy

set :ssh_options, {
  forward_agent: true,
  keys: [File.join(ENV["HOME"], ".ssh", "id_rsa_parti")],
  user: 'parti'
}

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Run db migration.
      execute "cd #{release_path}; RAILS_ENV=production bundle exec rake db:migrate"

      # Precompile assets on the staging server.
      execute "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"      

      # Create symlink to shared system directory where all attachments are stored.
      execute "cd #{release_path}/public; ln -s ../../../shared/system"

      # Restart the web app.
      execute "if [ ! -d #{release_path.join('tmp')} ]; then mkdir #{release_path.join('tmp')} && chmod 0777 #{release_path.join('tmp')}; fi"
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end
