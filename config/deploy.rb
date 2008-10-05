set :application, "hasmygembuiltyet"
set :repository,  "git@github.com:Floppy/hasmygembuiltyet.git"

set :deploy_to, "/var/www/hasmygembuiltyet.org"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, "git"
set :user, "root"

role :app, "67.207.134.233"
role :web, "67.207.134.233"
role :db,  "67.207.134.233", :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
