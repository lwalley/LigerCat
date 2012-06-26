require 'erb'

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

before 'deploy:setup', :database_yml, :workling_yml, :redis_yml
after  'deploy:update_code', 'database_yml:symlink', 'workling_yml:symlink', 'redis_yml:symlink', 'blast_binary:symlink', 'eol_list:symlink'
after  'deploy:update_code', 'passenger:chown'
after  :deploy, 'passenger:restart','workling:restart'

namespace :workling do
  desc "Starts the workling client"
  task :start, :roles => :worker_bee do
    run "RAILS_ENV=production #{current_path}/script/workling_client start"
  end
  
  desc "Stops the workling client"
  task :stop, :roles => :worker_bee do
    run "RAILS_ENV=production #{current_path}/script/workling_client stop"
  end
  
  desc "Restarts the workling client"
  task :restart, :roles => :worker_bee do
    stop rescue nil
    start
  end
end

namespace :passenger do
  desc "Start Application"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :stop, :roles => :app do
    # Do nothing.
  end
  
  desc "Chown RAILS_ROOT directory to nginx so Passenger does something that Ant says"
  task :chown do #, :roles => :app do 
    run "chown -R www-data:www-data #{release_path}"
  end
  
  # This is necessary if you want to use mod_rewrite
  desc "Removes the .htaccess file from /public"
  task :remove_htaccess do
    run "rm -f #{release_path}/public/.htaccess"
  end
end

namespace :blast_binary do
  desc "Make symlink to the correct blast binary"
  task :symlink do
    run "ln -nfs #{release_path}/lib/blast_bin/blastn-linux #{release_path}/lib/blast_bin/blastn"
    run "ln -nfs #{release_path}/lib/blast_bin/tblastn-linux #{release_path}/lib/blast_bin/t blastn"
  end
end

namespace :eol_list do
  desc "Make symlink to the list of EoL species"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/public/eol_ids_with_clouds.txt.gz #{release_path}/public/eol_ids_with_clouds.txt.gz"
  end
end

namespace :deploy do
  task :start do
    workling.start
    passenger.start rescue nil # This catches the error if we don't have an app server defined
  end
  
  task :restart do
    workling.restart
    passenger.restart rescue nil # This catches the error if we don't have an app server defined
  end
  
  task :stop do
    workling.stop
    passenger.stop rescue nil # This catches the error if we don't have an app server defined
  end
end

namespace :database_yml do
  desc "Create database.yml in shared path"
  task :default do
    db_config = ERB.new <<-EOF
      login: &login
        adapter: mysql
        username: root
        password: 
        host: localhost


      development:
        <<: *login
        database: ligercat_development

      test:
        <<: *login
        database: ligercat_test

      production:
        <<: *login
        database: ligercat_production
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config.result, "#{shared_path}/config/database.yml"
  end
  
  desc "Make symlink for database.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end


namespace :workling_yml do
  desc "Create workling.yml in shared path"
  task :default do
    workling_config = ERB.new <<-EOF
    # By default, NotRemoteRunner is used when RAILS_ENV == 'test'.
    #
    # You can pass options to memcached client by nesting the key value pairs
    # under 'memcache_options'.
    #

    production:
      listens_on: #{queue_server}:#{queue_port}
      
      # amqp_options are shared among all amqp adapters, including the tmm1-amqp aync adapter
      amqp_options:
        #host: localhost
        #port: 5672
        user: guest
        pass: 'guest'
        vhost: '/'
        logging: false

      sync_amqp_options:
        client:
          queue_options:
            durable: true
          message_options:
            persistent: true
        returnstore:
          queue_options:
            durable: true
          message_options:
            persistent: true

    development:
      listens_on: 192.168.16.131:5672 # rabbitmq
      # 5673 can be used if using tracer tool : http://www.rabbitmq.com/examples.html#tracer
      # The tracer utility works as a proxy between RabbitMQ and the workling client.
      sleep_time: 0.05

      # amqp_options are shared among all amqp adapters, including the tmm1-amqp aync adapter
      amqp_options:
        #host: localhost
        #port: 5672
        user: guest
        pass: 'guest'
        vhost: '/'
        logging: false

      sync_amqp_options:
        client:
          queue_options:
            durable: false
          message_options:
            persistent: false
        returnstore:
          queue_options:
            durable: false
          message_options:
            persistent: false

    test:
      listens_on: 192.168.16.131:5672
    EOF

    run "mkdir -p #{shared_path}/config"
    put workling_config.result, "#{shared_path}/config/workling.yml"
  end
  
  desc "Make symlink for workling.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/workling.yml #{release_path}/config/workling.yml"
  end
end

namespace :redis_yml do
  desc "Create redis.yml in shared path"
  task :default do
    redis_config = ERB.new <<-EOF
      # This Redis DB contains pmid -> mesh_id mappings
      mesh_development:
        hosts:
          - '128.128.164.226:6379'
          - '128.128.164.245:6379'
        database: 0

      mesh_test:
        host: 'localhost'
        port: 6379
        database: 0

      mesh_production:
        hosts: 
          - '128.128.164.226:6379'
          - '128.128.164.245:6379'
        database: 0


      # This Redis DB contains pmid -> date_published mappings
      date_published_development:
        hosts: 
          - '128.128.164.226:6379'
          - '128.128.164.245:6379'
        database: 1

      date_published_test:
        host: 'localhost'
        port: 6379
        database: 1

      date_published_production:
        hosts: 
          - '128.128.164.226:6379'
          - '128.128.164.245:6379'
        database: 1
    EOF

    run "mkdir -p #{shared_path}/config"
    put redis_config.result, "#{shared_path}/config/redis.yml"
  end
  
  desc "Make symlink for redis.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
  end
end