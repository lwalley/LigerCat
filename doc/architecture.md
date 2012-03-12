Ligercat Architecture
===================

Overview
-------------------------

The LigerCat architecture is comprised of the following components:

* Application servers (ligercat_app_server role)
* MySQL Database server (ligercat_mysql_master role)
* RabbitMQ AMQP messaging queue (ligercat_queue role)
* Redis key-value store (ligercat_cache role)
* workling worker-bee (ligercat_worker role)

The path of an incoming request to the app is as follows:

New search:
User enters search term -> app checks whether seach has been cached, if not, it adds the query to the database and the queue.
App begins polling database for status change
Worker-bee pools the queue, sees the item in the queue and begins to process it
Worker-bee looks up MeSH IDs for the query in redis and then returns the results to the database.
App database polling shows updated status, app renders results to User.

Cached search:
User enters search term -> app checks whether seach has been cached, returns cached html instantly.

Component detail
-----------------
* Application servers (ligercat_app_server role)
-- runs rails application
* MySQL Database server (ligercat_mysql_master role)
-- standard mysql 5.1.* install
* RabbitMQ AMQP messaging queue (ligercat_queue role)
-- standard rabbitMQ instance, no customizations
* Redis key-value store (ligercat_cache role)
-- Data is around 44GB in memory, due to old VM memory restrictions in our environment, this data is sharded over two 22GB nodes)
* workling worker-bee (ligercat_worker role)
-- runs as daemon from rails app code, small memory / OS footprint
