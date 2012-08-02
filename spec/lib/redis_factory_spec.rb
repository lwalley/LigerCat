require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'redis'
require 'redis/distributed'



describe RedisFactory do
  
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
        Rails.env = 'development'
        r = RedisFactory.gimme
        r.should be_a Redis
        r.client.host.should == 'dev_host'
        r.client.port.should == 6379
        r.client.db.should   == 0
        
        Rails.env = 'production'
        r = RedisFactory.gimme
        r.client.host.should == 'prod_host'
        r.client.port.should == 6381
        r.client.db.should   == 2
        
        Rails.env = 'test'
        r = RedisFactory.gimme
        r.client.host.should == 'test_host'
        r.client.port.should == 6380
        r.client.db.should   == 1
      end
    end
    
    describe "with a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("a_development:        \n"+
                                                "  host: 'a.dev.host'  \n"+
                                                "  port: 6379          \n"+
                                                "  database: 0         \n"+
                                                "a_test:               \n"+
                                                "  host: 'a.test.host' \n"+
                                                "  port: 6380          \n"+
                                                "  database: 1         \n"+
                                                "a_production:         \n"+
                                                "  host: 'a.prod.host' \n"+
                                                "  port: 6381          \n"+
                                                "  database: 2         \n"+
                                                "b_development:        \n"+
                                                "  host: 'b.dev.host'  \n"+
                                                "  port: 6382          \n"+
                                                "  database: 3         \n"+
                                                "b_test:               \n"+
                                                "  host: 'b.test.host' \n"+
                                                "  port: 6383          \n"+
                                                "  database: 4         \n"+
                                                "b_production:         \n"+
                                                "  host: 'b.prod.host' \n"+
                                                "  port: 6384          \n"+
                                                "  database: 5         \n")                                       
      end
      it '#gimme should return a Redis instance for each prefix and environment' do
        Rails.env = 'development'
        a = RedisFactory.gimme(:a)
        a.should be_a Redis
        a.client.host.should == 'a.dev.host'
        a.client.port.should == 6379
        a.client.db.should   == 0
        
        b = RedisFactory.gimme('b')
        b.client.host.should == 'b.dev.host'
        b.client.port.should == 6382
        b.client.db.should   == 3
        
        Rails.env =  'production'
        a = RedisFactory.gimme('a')
        a.client.host.should == 'a.prod.host'
        a.client.port.should == 6381
        a.client.db.should   == 2
        
        
        b = RedisFactory.gimme('b')
        b.client.host.should == 'b.prod.host'
        b.client.port.should == 6384
        b.client.db.should   == 5
        
        Rails.env =  'test'
        a = RedisFactory.gimme('a')
        a.client.host.should == 'a.test.host'
        a.client.port.should == 6380
        a.client.db.should   == 1
        
        b = RedisFactory.gimme('b')
        b.client.host.should == 'b.test.host'
        b.client.port.should == 6383
        b.client.db.should   == 4
      end
    end
  end
  
  describe 'with multiple hosts' do
    describe "without a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("development:             \n"+
                                                "  hosts:                 \n"+
                                                "    - 'dev.host1:6379'  \n"+
                                                "    - 'dev.host2:6379'  \n"+
                                                "  database: 0            \n"+
                                                "test:                    \n"+
                                                "  host: 'test_host'      \n"+
                                                "  port: 6380             \n"+
                                                "  database: 1            \n"+
                                                "production:              \n"+
                                                "  hosts:                 \n"+
                                                "    - 'prod.host1:6381' \n"+
                                                "    - 'prod.host2:6381' \n"+
                                                "  database: 2            \n" )
      end
      it '#gimme should return a Redis::Distributed instance for each environment with multiple hosts' do
        Rails.env =  'development'
        r = RedisFactory.gimme
        r.should be_a Redis::Distributed
        r.nodes[0].client.host.should == 'dev.host1'
        r.nodes[0].client.port.should == 6379
        r.nodes[0].client.db.should   == 0

        r.nodes[1].client.host.should == 'dev.host2'
        r.nodes[1].client.port.should == 6379
        r.nodes[1].client.db.should   == 0
        
        Rails.env =  'production'
        r = RedisFactory.gimme
        r.should be_a Redis::Distributed
        r.nodes[0].client.host.should == 'prod.host1'
        r.nodes[0].client.port.should == 6381
        r.nodes[0].client.db.should   == 2
        
        r.nodes[1].client.host.should == 'prod.host2'
        r.nodes[1].client.port.should == 6381
        r.nodes[1].client.db.should   == 2
        
        Rails.env =  'test'
        r = RedisFactory.gimme
        r.should be_a Redis
        r.client.host.should == 'test_host'
        r.client.port.should == 6380
        r.client.db.should   == 1
      end
    end
    
    describe "with a prefix" do
      before(:each) do
        RedisFactory.configurations = YAML.load("a_development:             \n"+
                                                "  hosts:                   \n"+
                                                "    - 'a.dev.host1:6379'  \n"+
                                                "    - 'a.dev.host2:6379'  \n"+
                                                "  database: 0              \n"+
                                                "a_test:                    \n"+
                                                "  host: 'a.test.host'      \n"+
                                                "  port: 6380               \n"+
                                                "  database: 1              \n"+
                                                "a_production:              \n"+
                                                "  hosts:                   \n"+
                                                "    - 'a.prod.host1:6381' \n"+
                                                "    - 'a.prod.host2:6381' \n"+
                                                "  database: 2              \n"+
                                                "b_development:             \n"+
                                                "  hosts:                   \n"+
                                                "    - 'b.dev.host1:6382'  \n"+
                                                "    - 'b.dev.host2:6382'  \n"+
                                                "  database: 3              \n"+
                                                "b_test:                    \n"+
                                                "  host: 'b.test.host'      \n"+
                                                "  port: 6383               \n"+
                                                "  database: 4              \n"+
                                                "b_production:              \n"+
                                                "  hosts:                   \n"+
                                                "   - 'b.prod.host1:6384'  \n"+
                                                "   - 'b.prod.host2:6384'  \n"+
                                                "  database: 5              \n")                                       
      end
      it '#gimme should return a Redis::Distributed instance for each prefix and environment with multiple hosts' do
        Rails.env =  'development'
        a = RedisFactory.gimme('a')
        a.should be_a Redis::Distributed
        a.nodes[0].client.host.should == 'a.dev.host1'
        a.nodes[0].client.port.should == 6379
        a.nodes[0].client.db.should   == 0
        a.nodes[1].client.host.should == 'a.dev.host2'
        a.nodes[1].client.port.should == 6379
        a.nodes[1].client.db.should   == 0
        
        b = RedisFactory.gimme('b')
        b.should be_a Redis::Distributed
        b.nodes[0].client.host.should == 'b.dev.host1'
        b.nodes[0].client.port.should == 6382
        b.nodes[0].client.db.should   == 3
        b.nodes[1].client.host.should == 'b.dev.host2'
        b.nodes[1].client.port.should == 6382
        b.nodes[1].client.db.should   == 3
        
        Rails.env =  'production'
        a = RedisFactory.gimme('a')
        a.should be_a Redis::Distributed
        a.nodes[0].client.host.should == 'a.prod.host1'
        a.nodes[0].client.port.should == 6381
        a.nodes[0].client.db.should   == 2
        a.nodes[1].client.host.should == 'a.prod.host2'
        a.nodes[1].client.port.should == 6381
        a.nodes[1].client.db.should   == 2
        
        b = RedisFactory.gimme('b')
        b.should be_a Redis::Distributed
        b.nodes[0].client.host.should == 'b.prod.host1'
        b.nodes[0].client.port.should == 6384
        b.nodes[0].client.db.should   == 5
        b.nodes[1].client.host.should == 'b.prod.host2'
        b.nodes[1].client.port.should == 6384
        b.nodes[1].client.db.should   == 5
        
        Rails.env =  'test'
        a = RedisFactory.gimme('a')
        a.should be_a Redis
        a.client.host.should == 'a.test.host'
        a.client.port.should == 6380
        a.client.db.should   == 1
        
        b = RedisFactory.gimme('b')
        b.should be_a Redis
        b.client.host.should == 'b.test.host'
        b.client.port.should == 6383
        b.client.db.should   == 4
      end
    end
  end
end