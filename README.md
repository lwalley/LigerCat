LigerCat
========

LigerCat (ligercat.org) is a search tool for the [NCBI's PubMed] (http://www.ncbi.nlm.nih.gov/pubmed/) that uses tag clouds to provide an overview of important concepts and trends.

Installing LigerCat
-------------------

LigerCat is a Ruby on Rails application. The following instructions assume you are familiar with and using [Ruby Version Manager] (http://beginrescueend.com) and [Bundler] (http://gembundler.com/).

### Requirements
* Ruby
* Git
* MySQL 5.0 +
* Redis

### Download source code
Clone the LigerCat application code to your machine:

READ ONLY:
    $ git clone git://github.com/mbl-cli/LigerCat.git

Or READ/WRITE:
    $ git clone git@github.com:mbl-cli/LigerCat.git

### Installing Ruby with RVM
LigerCat uses a _.rvmrc_ file, located in the root directory (ROOTDIR/.rvmrc) of the application, to tell RVM which version of Ruby is required. When you navigate to ROOTDIR, RVM should warn you if you do not have the required version of Ruby installed.

If the Ruby version required is not yet installed, follow the RVM instructions to install it, e.g.
    $ rvm install ruby-1.8.7

Once you have installed Ruby with RVM, re-enter the ROOTDIR directory and the _.rvmrc_ file will instruct RVM to create the ligercat gemset, if it does not exist.

### Installing gems with bundler
From LigerCat's ROOTDIR check that you are using the correct version of Ruby and that the ligercat gemset is selected before proceeding:
    $ cd .
    $ rvm list
    $ rvm gemset list

LigerCat uses [Bundler] (http://gembundler.com/) to manage it's Ruby gem dependencies. The required gems are defined in ROOTDIR/Gemfile. From LigerCat's ROOTDIR download the bundler gem, check it is installed and then execute bundle install to download LigerCat's required gems:
    $ gem install bundler
    $ gem list
    $ bundle install

Configuring LigerCat
--------------------
LigerCat makes use of Rails environments and YAML configuration files to store the settings required by the application.Configuration files are located in ROOTDIR/config.

### Configure database
LigerCat users [MySQL] (http://www.mysql.com/) database. Rename ROOTDIR/config/database.yml.example to ROOTDIR/config/database.yml and edit settings as required, ensuring that your MySQL user has create and update databases privileges.

### Configure Redis
LigerCat uses [Redis] (http://redis.io/) key-value store. Rename ROOTDIR/config/redis.yml.example to ROOTDIR/config/redis.yml and edit settings as required.

### Configure private settings
LigerCat relies on environment settings, such as email addresses and private keys that we prefer to keep seperate from the public repository, and so we load them from a YAML file. Rename ROOTDIR/config/private.yml.example to ROOTDIR/config/private.yml and edit settings as required.

### Configure blast binary
WARNING: blastcl3 is deprecated this configuration requirement is subject to change:
Create a symbolic link for the Blast Binary (only if required, note that Mac OS X creates the symlink for you automagically):
    $ ln -nfs lib/blast_bin/blastcl3-linux lib/blast_bin/blastcl3

Seeding LigerCat database and Redis
-----------------------------------
TODO: Update this section
WARNING: The LigerCat database can take up more than 11 GB of hard disk space. Running migrations (populating the database) can take up to an hour or more.

Create LigerCat database:
    $ rake db:create

Populate the LigerCat database - WARNING: may take more than an hour:
    $ rake db:migrate


Running LigerCat in Development mode
------------------------------------
LigerCat requires a Web server, Redis and Resque to be running.

### Start Redis
Redis is required by both Resque and by the LigerCat application. Start your Redis server first:
    $ redis-server

### Start Resque
For more information refer to the [Resque documentation] (https://github.com/defunkt/resque)

Resque provides a Web interface that you can use to monitor queues and jobs. From the LigerCat ROOTDIR start the Resque Web application:
    $ resque-web ./config/initializers/resque.rb

Open a Web browser and navigate to [http://0.0.0.0:5678/] (http://0.0.0.0:5678)

LigerCat uses two queues one for new queries requested by Web users and one for updating existing cached searches. Launch a worker to listen to those two queues in priority order:
    $ QUEUE=new_queries,refresh_cached_queries rake environment resque:work

### Start the Web server
From LigerCat ROOTDIR start the Web server:
    $ script/server

Open a Web browser and navigate to [http://0.0.0.0:3000] (http://0.0.0.0:3000)


Production Mode
---------------
LigerCat cannot be run in a production environment by the method detailed above.

We at the MBL run LigerCat using Apache + Phusion Passenger, although there's nothing stopping you from using Mongrel or Thin behind an Apache or Nginx proxy.

Effectively hosting a Rails application in a production environment is beyond the scope of this document, however we have included a sample Capfile that we use to deploy to Phusion Passenger.


TODO make sure the server's timezone is Eastern 
TODO Update capfile to tell whenever to install crontab
