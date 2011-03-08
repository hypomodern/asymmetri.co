if ENV["TARGET"].nil?
  puts "TARGET was unspecified... defaulting to 'master'"
end
set :user, "root"
set :target, ENV["TARGET"] || "master"
role :web, "skunkworks.hypomodern.com"

namespace :deploy do
  namespace :hypnocube do
    set :application, "asymmetri.co"
    set :app_path, "/var/sites/#{application}"
    set :current_path, "/var/#{application}-git"
    set :repo, "git@github.com:hypomodern/#{application}.git"
    set :branch, "origin/master"

    desc "updates the server-cached git repo, symlinks the theme into the WP install"
    task :default, :roles => :web do
      update_code
      # prep
      restart
      # cleanup
    end

    desc "Sets up the server-side git structure"
    task :setup, :roles => :web, :except => { :no_release => true } do
      run "mkdir -p #{current_path}"
      run "git clone #{repo} #{current_path}; cd #{current_path}; git reset --hard #{branch}"
    end

    desc "Update the deployed code."
    task :update_code, :roles => :web, :except => { :no_release => true } do
      run "cd #{current_path}; git checkout #{target}; git fetch origin; git reset --hard #{branch}"
    end

    desc "Rollback a single commit."
    task :rollback, :roles => :web, :except => { :no_release => true } do
      set :branch, "HEAD^"
      default
    end

    desc "PHP: nothing needs to be restarted. Everyone be cool :)"
    task :restart, :roles => :web do
    end

    desc "preps the filesystem... chmods, symlinks, etc."
    task :prep, :roles => :web do
      run "chown -R www-data:www-data #{app_path}"
      run "ln -s #{current_path}/theme #{app_path}/wp-content/themes/#{application}"
    end
  end
end