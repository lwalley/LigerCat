# LigerCat #
LigerCat [ligercat.org](ligercat.org) is a search tool for the [NCBI's PubMed](http://www.ncbi.nlm.nih.gov/pubmed/) that uses tag clouds to provide an overview of important concepts and trends.

The [LigerCat source code](https://github.com/mbl-cli/LigerCat) has been built using [Ruby on Rails](http://rubyonrails.org/) version 3 framework, and makes use of [MySQL](http://mysql.com) and [Redis](http://redis.io) data storage.

## About this README ##
This README is intended primarily for developers who want to get LigerCat up and running in their local development environment, and is based on our experiences running LigerCat in development mode on Mac OS X machines. This README does not provide instructions on building the environment needed for running LigerCat in production mode. However, we have highlighted the rake tasks that you would need to execute in order to keep the application data up to date in a production environment.

The installation instructions assume you are familiar with and using [Ruby Version Manager](https://rvm.io/) and [Bundler](http://gembundler.com/) with `.rvmrc` and gemsets. If you are new to RVM read [RVM Basics](https://rvm.io/rvm/basics) to get you started.

### Conventions ###
`Rails.root` -- When you install the LigerCat Rails application into a directory on your machine e.g. `/Users/username/dev/LigerCat` we will refer to that application root directory as `Rails.root`.

Assume all command-line commands should be executed from `Rails.root` unless we indicate otherwise. Command-line commands are prefixed with `$` and indicated with a code block e.g.:

    $ some command


## Installing LigerCat ##
You should already have the following tools installed on your machine. We do not cover the installation of these tools in the README, but we do recommend using [Homebrew](http://mxcl.github.com/homebrew/) package manager for OS X.

* [Ruby Version Manager (RVM)](https://rvm.io/rvm/install/)
* [Git](http://git-scm.com/downloads/)
* [MySQL 5.0 +](http://dev.mysql.com/)
* [Redis 2.4.14](http://redis.io/download/)

### Download source code ###

Using Git, clone the [LigerCat source code](https://github.com/mbl-cli/LigerCat) to your machine:

READ ONLY:

    $ git clone git://github.com/mbl-cli/LigerCat.git

Or READ/WRITE:

    $ git clone git@github.com:mbl-cli/LigerCat.git

### Install Ruby and create gemset ###

LigerCat's `.rvmrc` file, located in `Rails.root`, instructs RVM which version of Ruby and which gemset to use. When you change directory into `Rails.root` for the first time, RVM will switch to the correct version of Ruby and will create the `ligercat` gemset and output a statement such as `Using /Users/username/.rvm/gems/ruby-1.9.3-p194 with gemset ligercat`.

If you do not have the required version of Ruby, RVM usually shows a warning with instructions on how to install it e.g.:

    $ rvm install ruby-1.9.3

After installing the required Ruby version reload (exit and re-enter i.e. `$ cd .`) the `Rails.root` directory to trigger RVM to use the new version of Ruby and to create the `ligercat` gemset.

    $ cd .

You can can also check which Ruby and gemset you are using with the following commands:

    $ rvm list
    $ rvm gemset list

### Install gems ###

LigerCat uses [Bundler](http://gembundler.com/) to manage it's Ruby gem dependencies. RVM typically installs `bundler` in a global gemset when you install Ruby, you can check what gems are already installed with:

    $ gem list

If you do not already have `bundler` installed download it now using:

    $ gem install bundler

The gems LigerCat's needs are listed in `Rails.root/Gemfile`. Use bundler to install these gems:

    $ bundle install

## Configuring LigerCat ##

LigerCat makes use of Rails environments and YAML configuration files to store the settings required by the application. Configuration files are located in `Rails.root/config`.

### Configure database ###

LigerCat uses [MySQL](http://www.mysql.com/) database. Copy and rename `Rails.root/config/database.yml.example` to `Rails.root/config/database.yml` and edit settings as required, ensuring that your MySQL user has create and update databases privileges:

    $ cp config/database.yml.example config/database.yml

### Configure Redis ###

LigerCat uses [Redis](http://redis.io/) key-value store. Copy and rename `Rails.root/config/redis.yml.example` to `Rails.root/config/redis.yml` and edit settings as required:

    $ cp config/redis.yml.example config/redis.yml

### Configure private settings ###

LigerCat relies on environment settings, such as email addresses and private keys that we prefer to keep seperate from the public repository, and so we load them from a YAML file. Copy and rename `Rails.root/config/private.yml.example` to `Rails.root/config/private.yml` and edit settings as required:

    $ cp config/private.yml.example config/private.yml

### Configure Blast+ (not necessary on Mac OS X) ###

LigerCat uses [Blast+](http://www.ncbi.nlm.nih.gov/books/NBK1762/) `blastn` and `tblastn` binaries to perform remote BLAST queries. The binary files for Mac OS X and Linux systems are included in `Rails.root/lib/blast_bin/`.

Note that `blastn` and `tblastn` are symlinks to `blastn-mac` and `tblastn-mac` which are the binaries required when running LigerCat on Mac OS X. To use the Linux binaries simply update the `blastn` and `tblastn` symlinks to point to the Linux binary files. When deploying to production machines we manage the configuration of the Blast symbolic links using [Capistrano](https://github.com/capistrano/capistrano), refer to the sample `Rails.root/Capfile` for more information. To switch the symlinks manually you can use:

    $ ln -nfs lib/blast_bin/blastn-linux lib/blast_bin/blastn
    $ ln -nfs lib/blast_bin/tblastn-linux lib/blast_bin/tblastn

## Seeding LigerCat database and Redis ##
LigerCat uses data from both MySQL and Redis. Some of the MySQL data must be in place before LigerCat can perform queries. Other data, including that in Redis will be generated over time as the application is used, however performance can be improved if this data is also preloaded.

The following instructions will create databases and seed data for your default Rails environment, usually development. If you wish to create databases and seed data for other environments you can use e.g. `rake db:create RAILS_ENV=production`

### Create database ###

    $ rake db:create

### Run migrations ###

    $ rake db:migrate

### Pre-populate MySQL with seed data ###

We remotely host CSV files which will be automatically downloaded and used to seed your environment's database. The following rake task will download the seed files to `Rails.root/tmp/seed_downloads/` and import the data into your database. You will need to be connected to the Internet when performing this task. 

WARNING: The last table to seed, `gi_numbers_pmids`, can take several hours to populate. This table is only necessary for doing Blast searches. Although inadvisable, in development mode you can cancel the rake task during this seed by pressing CTRL-C, as long as you're not planning on making any Blast searches. If at a later date you want to perform Blast searches, run the rake task again to reload the data.

    $ rake db:seed

## Running LigerCat in development mode ##

LigerCat requires a Web server, Redis and a Resque worker to be running.

### Start Redis ###

For more information refer to the [Redis documentation](http://redis.io/documentation)

Redis is required by both Resque and by the LigerCat application. Start your Redis server first, you may need to pass in a config file on start up:

    $ redis-server /path/to/redis.conf

### Start a Resque Worker ###

For more information refer to the [Resque documentation](https://github.com/defunkt/resque)

Resque provides a Web interface that you can use to monitor queues and jobs. From the LigerCat `Rails.root` start the Resque Web application:

    $ resque-web ./config/initializers/resque.rb

Open a Web browser and navigate to [http://0.0.0.0:5678/](http://0.0.0.0:5678)

LigerCat uses three queues: one for new queries requested by Web users, one for building clouds for species from the Encyclopedia of Life, and one for updating existing cached searches. Launch a worker to listen to those queues in priority order:

    $ QUEUE=new_queries,eol_taxa,refresh_cached_queries rake environment resque:work

### Start the Web server ###

From LigerCat `Rails.root` start the Web server:

    $ rails s

Open a Web browser and navigate to [http://0.0.0.0:3000](http://0.0.0.0:3000)

## Running LigerCat in production mode ##

Redis is an in-memory database and since LigerCat stores about 40 million keys, 20 million of which contain sets of multiple values, it requires a significant amount of memory to run in a production environment. #TODO: estimate how much memory is needed. It may be advantageous to shard the Redis database across multiple hosts, as suggested in the production section of `Rails.root/config/redis.yml.example`. The LigerCat MySQL database will require a minimum of 2GB of hard disk space.

We run LigerCat in production using NGinx and Unicorn, although there's nothing stopping you from using Passenger, Mongrel or Thin behind an Apache or Nginx proxy. Our production environment settings and deployments are managed with [Capistrano](https://github.com/capistrano/capistrano) and we have provided a sample Capfile `Rails.root/Capfile`.

### Refreshing cached queries ###

LigerCat's tag clouds and histograms are cached when first built. Overtime NLM releases new data and so LigerCat's cached queries need to be refreshed. We make use of the [whenever Ruby gem](https://github.com/javan/whenever) to deploy a cron job that triggers the rebuilding of cached queries. NLM recommends using their services between the hours of 5pm and 9am Eastern, and we have scheduled the cron job to execute during those times, however the cron job is not aware of timezones so in order to comply with the NLM recommendations you should set your application server's timezone to Eastern or modify `Rails.root/config/schedule.rb` accordingly.

### Keeping lookup data up to date ###

LigerCat tag cloud terms consist of the [National Library of Medicine's (NLM)](http://http://www.nlm.nih.gov) [Medical Subject Headings (MeSH)](http://www.nlm.nih.gov/mesh/MBrowser.html). The relative size of a MeSH term in a tag cloud is based on a score that is calculated using the term's frequency count across MEDLINE. Each year the NLM releases new MeSH terms, and the [MEDLINE Baseline Repository (MBR)](http://mbr.nlm.nih.gov/) provides updated frequncy counts.

For performance reasons LigerCat stores these MeSH terms, their IDs and their scores locally (see `Rails.root/lib/mesh_keyword_lookup.rb` and `Rails.root/lib/mesh_score_lookup.rb`). NLM updates the MeSH vocabulary once a year, and consequently this locally stored lookup data needs to be updated. LigerCat can detect when this is necesary, and will attempt to send an email notification to `feedback_recipients` when it encounters a new MeSH term. You can configure `feedback_recipients` email addresses in `Rails.root/config/private.yml`.

We have included rake tasks to update the lookup data, first simply download the most recent version of the raw data file from [MBR files](http://mbr.nlm.nih.gov/Download/index.shtml), then run:

    $ rake mesh:create_indexes[path_to_mh_freq_count]

Once you have updated the lookups, you will need to use Capistrano to deploy the application to production, and update the production database with the new terms

    $ rake mesh:seed RAILS_ENV=production

## Acknowledgements ##

* [MEDLINE Baseline Repository](http://mbr.nlm.nih.gov) for providing [frequency counts](http://mbr.nlm.nih.gov/Download/index.shtml) for each unique MeSH Heading found in MEDLINE for a given baseline year.
