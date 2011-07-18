require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'redis'
require 'dist_redis'


# Monkey patches to provide easy access to Redis instance vars
class Redis
  def host; @host; end
  def port; @port; end
  def db; @db; end
end

describe RedisFactory do
  it "should read config/redis.yml" do
    RedisFactory.configurations.should == YAML.load_file(RAILS_ROOT + '/config/redis.yml')
  end
  
  it "should raise an exception if the configuration could not be loaded for the environment and prefix" do
    lambda{ RedisFactory.gimme("a_prefix_that_doesn't_exist") }.should raise_error
  end
  
  describe 'with single host' do
    describe "without a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("development:        \n"+
                                                "  host: 'dev_host'  \n"+
                                                "  port: 6379        \n"+
                                                "  database: 0       \n"+
                                                "test:               \n"+
                                                "  host: 'test_host' \n"+
                                                "  port: 6380        \n"+
                                                "  database: 1       \n"+
                                                "production:         \n"+
                                                "  host: 'prod_host' \n"+
                                                "  port: 6381        \n"+
                                                "  database: 2       \n" )
      end
      it '#gimme should return a Redis instance for each environment' do
        Rails.stub!(:env).and_return 'development'
        r = RedisFactory.gimme
        r.should be_a Redis
        r.host.should == 'dev_host'
        r.port.should == 6379
        r.db.should   == 0
        
        Rails.stub!(:env).and_return 'production'
        r = RedisFactory.gimme
        r.host.should == 'prod_host'
        r.port.should == 6381
        r.db.should   == 2
        
        Rails.stub!(:env).and_return 'test'
        r = RedisFactory.gimme
        r.host.should == 'test_host'
        r.port.should == 6380
        r.db.should   == 1
      end
    end
    
    describe "with a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("a_development:        \n"+
                                                "  host: 'a_dev_host'  \n"+
                                                "  port: 6379          \n"+
                                                "  database: 0         \n"+
                                                "a_test:               \n"+
                                                "  host: 'a_test_host' \n"+
                                                "  port: 6380          \n"+
                                                "  database: 1         \n"+
                                                "a_production:         \n"+
                                                "  host: 'a_prod_host' \n"+
                                                "  port: 6381          \n"+
                                                "  database: 2         \n"+
                                                "b_development:        \n"+
                                                "  host: 'b_dev_host'  \n"+
                                                "  port: 6382          \n"+
                                                "  database: 3         \n"+
                                                "b_test:               \n"+
                                                "  host: 'b_test_host' \n"+
                                                "  port: 6383          \n"+
                                                "  database: 4         \n"+
                                                "b_production:         \n"+
                                                "  host: 'b_prod_host' \n"+
                                                "  port: 6384          \n"+
                                                "  database: 5         \n")                                       
      end
      it '#gimme should return a Redis instance for each prefix and environment' do
        Rails.stub!(:env).and_return 'development'
        a = RedisFactory.gimme(:a)
        a.should be_a Redis
        a.host.should == 'a_dev_host'
        a.port.should == 6379
        a.db.should   == 0
        
        b = RedisFactory.gimme('b')
        b.host.should == 'b_dev_host'
        b.port.should == 6382
        b.db.should   == 3
        
        Rails.stub!(:env).and_return 'production'
        a = RedisFactory.gimme('a')
        a.host.should == 'a_prod_host'
        a.port.should == 6381
        a.db.should   == 2
        
        
        b = RedisFactory.gimme('b')
        b.host.should == 'b_prod_host'
        b.port.should == 6384
        b.db.should   == 5
        
        Rails.stub!(:env).and_return 'test'
        a = RedisFactory.gimme('a')
        a.host.should == 'a_test_host'
        a.port.should == 6380
        a.db.should   == 1
        
        b = RedisFactory.gimme('b')
        b.host.should == 'b_test_host'
        b.port.should == 6383
        b.db.should   == 4
      end
    end
  end
  
  describe 'with multiple hosts' do
    describe "without a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("development:             \n"+
                                                "  hosts:                 \n"+
                                                "    - 'dev_host_1:6379'  \n"+
                                                "    - 'dev_host_2:6379'  \n"+
                                                "  database: 0            \n"+
                                                "test:                    \n"+
                                                "  host: 'test_host'      \n"+
                                                "  port: 6380             \n"+
                                                "  database: 1            \n"+
                                                "production:              \n"+
                                                "  hosts:                 \n"+
                                                "    - 'prod_host_1:6381' \n"+
                                                "    - 'prod_host_2:6381' \n"+
                                                "  database: 2            \n" )
      end
      it '#gimme should return a DistRedis instance for each environment with multiple hosts' do
        Rails.stub!(:env).and_return 'development'
        r = RedisFactory.gimme
        r.should be_a DistRedis
        r.ring.nodes[0].host.should == 'dev_host_1'
        r.ring.nodes[0].port.should == 6379
        r.ring.nodes[0].db.should   == 0
        
        r.ring.nodes[1].host.should == 'dev_host_2'
        r.ring.nodes[1].port.should == 6379
        r.ring.nodes[1].db.should   == 0
        
        Rails.stub!(:env).and_return 'production'
        r = RedisFactory.gimme
        r.should be_a DistRedis
        r.ring.nodes[0].host.should == 'prod_host_1'
        r.ring.nodes[0].port.should == 6381
        r.ring.nodes[0].db.should   == 2
        
        r.ring.nodes[1].host.should == 'prod_host_2'
        r.ring.nodes[1].port.should == 6381
        r.ring.nodes[1].db.should   == 2
        
        Rails.stub!(:env).and_return 'test'
        r = RedisFactory.gimme
        r.should be_a Redis
        r.host.should == 'test_host'
        r.port.should == 6380
        r.db.should   == 1
      end
    end
    
    describe "with a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("a_development:             \n"+
                                                "  hosts:                   \n"+
                                                "    - 'a_dev_host_1:6379'  \n"+
                                                "    - 'a_dev_host_2:6379'  \n"+
                                                "  database: 0              \n"+
                                                "a_test:                    \n"+
                                                "  host: 'a_test_host'      \n"+
                                                "  port: 6380               \n"+
                                                "  database: 1              \n"+
                                                "a_production:              \n"+
                                                "  hosts:                   \n"+
                                                "    - 'a_prod_host_1:6381' \n"+
                                                "    - 'a_prod_host_2:6381' \n"+
                                                "  database: 2              \n"+
                                                "b_development:             \n"+
                                                "  hosts:                   \n"+
                                                "    - 'b_dev_host_1:6382'  \n"+
                                                "    - 'b_dev_host_2:6382'  \n"+
                                                "  database: 3              \n"+
                                                "b_test:                    \n"+
                                                "  host: 'b_test_host'      \n"+
                                                "  port: 6383               \n"+
                                                "  database: 4              \n"+
                                                "b_production:              \n"+
                                                "  hosts:                   \n"+
                                                "   - 'b_prod_host_1:6384'  \n"+
                                                "   - 'b_prod_host_2:6384'  \n"+
                                                "  database: 5              \n")                                       
      end
      it '#gimme should return a DistRedis instance for each prefix and environment with multiple hosts' do
        Rails.stub!(:env).and_return 'development'
        a = RedisFactory.gimme('a')
        a.should be_a DistRedis
        a.ring.nodes[0].host.should == 'a_dev_host_1'
        a.ring.nodes[0].port.should == 6379
        a.ring.nodes[0].db.should   == 0
        a.ring.nodes[1].host.should == 'a_dev_host_2'
        a.ring.nodes[1].port.should == 6379
        a.ring.nodes[1].db.should   == 0
        
        b = RedisFactory.gimme('b')
        b.should be_a DistRedis
        b.ring.nodes[0].host.should == 'b_dev_host_1'
        b.ring.nodes[0].port.should == 6382
        b.ring.nodes[0].db.should   == 3
        b.ring.nodes[1].host.should == 'b_dev_host_2'
        b.ring.nodes[1].port.should == 6382
        b.ring.nodes[1].db.should   == 3
        
        Rails.stub!(:env).and_return 'production'
        a = RedisFactory.gimme('a')
        a.should be_a DistRedis
        a.ring.nodes[0].host.should == 'a_prod_host_1'
        a.ring.nodes[0].port.should == 6381
        a.ring.nodes[0].db.should   == 2
        a.ring.nodes[1].host.should == 'a_prod_host_2'
        a.ring.nodes[1].port.should == 6381
        a.ring.nodes[1].db.should   == 2
        
        b = RedisFactory.gimme('b')
        b.should be_a DistRedis
        b.ring.nodes[0].host.should == 'b_prod_host_1'
        b.ring.nodes[0].port.should == 6384
        b.ring.nodes[0].db.should   == 5
        b.ring.nodes[1].host.should == 'b_prod_host_2'
        b.ring.nodes[1].port.should == 6384
        b.ring.nodes[1].db.should   == 5
        
        Rails.stub!(:env).and_return 'test'
        a = RedisFactory.gimme('a')
        a.should be_a Redis
        a.host.should == 'a_test_host'
        a.port.should == 6380
        a.db.should   == 1
        
        b = RedisFactory.gimme('b')
        b.should be_a Redis
        b.host.should == 'b_test_host'
        b.port.should == 6383
        b.db.should   == 4
      end
    end
  end
end