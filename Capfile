require 'erb'

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

after  'deploy:update_code', 'database_yml:symlink','unicorn:symlink', 'private_yml:symlink', 'redis_yml:symlink', 'blast_binary:symlink', 'eol_list:symlink'


namespace :blast_binary do
  desc "Make symlink to the correct blast binary"
  task :symlink do
    run "ln -nfs #{release_path}/lib/blast_bin/blastn-linux #{release_path}/lib/blast_bin/blastn"
    run "ln -nfs #{release_path}/lib/blast_bin/tblastn-linux #{release_path}/lib/blast_bin/tblastn"
  end
end

namespace :eol_list do
  desc "Make symlink to the list of EoL species"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/public/eol_ids_with_clouds.txt.gz #{release_path}/public/eol_ids_with_clouds.txt.gz"
  end
end

namespace :database_yml do
  desc "Make symlink for database.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

namespace :unicorn do
  desc "Symlink unicorn config"
  task :symlink do
    run "mkdir -p #{release_path}/config/unicorn/"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/unicorn/#{rails_env}.rb #{release_path}/config/unicorn/#{rails_env}.rb"
  end
end

namespace :private_yml do
  desc "Make symlink for private.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/private.yml #{release_path}/config/private.yml"
  end
end

namespace :redis_yml do
  desc "Make symlink for redis.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
  end
end
