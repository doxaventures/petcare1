# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "petstore"
set :repo_url, "git@bitbucket.org:ravisampath/petcare.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/session_secret', 'config/config.yml', 'config/secrets.yml', 'config/thinking_sphinx.yml', 'config/production.sphinx.conf')

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/images', 'db/sphinx', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# before 'deploy:compile_assets', 'deploy:migrate'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      if test("[ -f #{fetch(:unicorn_pid)} ]")
        execute :kill, capture(:cat, fetch(:unicorn_pid))
      end
    end

    invoke 'unicorn:restart'
    invoke 'unicorn:legacy_restart' # cleanup your oldbin pid use
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake tmp:cache:clear'
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:cleanup'
  after 'deploy:finished', 'deploy:restart'

end

# Thinking sphinx
namespace :sphinx do
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake ts:stop'
        end
      end
    end
  end

  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake ts:rebuild'
        end
      end
    end
  end
end

after 'deploy:updated', 'sphinx:stop'
after 'deploy:finished', 'sphinx:start'

# Delayed job
namespace :delayed_job do
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec script/delayed_job stop'
        end
      end
    end
  end

  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec script/delayed_job start'
        end
      end
    end
  end
end

after 'deploy:updated', 'delayed_job:stop'
after 'deploy:finished', 'delayed_job:start'
