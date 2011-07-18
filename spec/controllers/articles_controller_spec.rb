require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'hpricot'

describe ArticlesController do
  describe "- route recognition" do
    it "GET /articles should generate params { :controller => 'articles', :action => 'new' }" do
      params_from(:get, "/articles").should == {:controller => "articles", :action => "new"}
    end
    
    it "POST /articles should generate params { :controller => 'articles', :action => 'create' }" do
      params_from(:post, "/articles").should == {:controller => "articles", :action => "create"}
    end
    
    it "GET /articles/123 should generate params { :controller => 'articles', :action => 'show', :id => '123' }" do
      params_from(:get, "/articles/123").should == {:controller => "articles", :action => "show", :id => '123'}
    end
    
    it "GET /articles/biology should generate params { :controller => 'articles', :action => 'create_or_show', :q => 'biology' }" do
      params_from(:get, "/articles/biology").should == {:controller => "articles", :action => "create_or_show", :q => 'biology'}
    end
    
    it "GET /articles/Mr.%20T should generate params { :controller => 'articles', :action => 'create_or_show', :q => 'Mr. T' }" do
      params_from(:get, "/articles/Mr.%20T").should == {:controller => "articles", :action => "create_or_show", :q => 'Mr. T'}
    end
    
    it "GET /articles/1234/status should generate params { :controller => 'articles', :action => 'status', :id => '1234' }" do
      params_from(:get, "/articles/1234/status").should == {:controller => "articles", :action => "status", :id => '1234'}
    end
    
    it "GET /articles/1234/status.json should generate params { :controller => 'articles', :action => 'status', :id => '1234', :format => 'json' }" do
      params_from(:get, "/articles/1234/status.json").should == {:controller => "articles", :action => "status", :id => '1234', :format => 'json'}
    end
    
    it "GET /articles/1234.cloud should generate params { :controller => 'articles', :action => 'show', :id => '1234', :format => 'cloud' }" do
      params_from(:get, "/articles/1234.cloud").should == { :controller => 'articles', :action => 'show', :id => '1234', :format => 'cloud' }
    end
  end
end


describe 'GET /articles' do
  controller_name find_controller_name(:get, '/articles')
  integrate_views
  
  before(:each) do
    do_get('/articles')
  end

  it "should render the 'intro' page with the articles tab selected" do
    response.should render_template("articles/new")
    response.should have_tag(".navigation li.articles.active")
  end
end

describe 'GET /articles/{pubmed_query} GIVEN a pubmed_query that does not exist in the database' do
  controller_name :articles
  integrate_views
  
  before(:all) do
    @query = "Biology"
    @url = "/articles/#{@query}"
  end
  
  before(:each) do
    # Mock to prevent Workling from actually running
    PubmedWorker.stub!(:async_execute_search)
  end
  
  it "should check the database for an existing record" do
    PubmedQuery.should_receive(:find_by_query).with(@query).and_return(nil)
    do_get @url
  end
  
  it "should create a new PubmedQuery" do
    PubmedQuery.should_receive(:create).with(:query => @query).and_return(mock_model(PubmedQuery))
    do_get @url
  end
  
  it "should kick off a background worker" do
    PubmedWorker.should_receive(:async_execute_search)
    do_get @url
  end
  
  it "should redirect the user to a status page for the query they just created" do
    do_get @url
    gene_id = assigns[:query].id
    response.should redirect_to("/articles/#{gene_id}/status")
  end
end

describe 'GET /articles/{pubmed_query} GIVEN a pubmed_query that exists in the database and is still Searching' do
  controller_name :articles
  integrate_views
  fixtures :pubmed_queries
  
  before(:each) do
    @query = pubmed_queries(:still_searching).query
    @url = "/articles/#{@query}"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  it "should check the database for an existing record" do
    PubmedQuery.should_receive(:find_by_query).with(@query).and_return( pubmed_queries(:still_searching) )
    do_get @url
  end
  
  it "should redirect to the status page for that sequence" do
    do_get @url
    gene_id = pubmed_queries(:still_searching).id
    response.should redirect_to("/articles/#{gene_id}/status")
  end
end

describe "an article's 'show' page", :shared => true do
  it "should show the tag cloud for that sequence" do
    do_get @url
    response.should have_tag('ol.keyword_cloud') do
      with_tag("li a", 'Biodiversity')
      with_tag('li a', 'Computational Biology')
    end
  end
  
  it "should show the query in the articles text input" do
    do_get @url
    response.should have_tag('input#articles_q[value=?]', @query)
  end
end

describe 'GET /articles/{pubmed_query} GIVEN a pubmed_query that exists in the database and is DONE Searching' do
  controller_name :articles
  fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  integrate_views
  
  before(:each) do
    @query = pubmed_queries(:biodiversity_informatics).query
    @url = "/articles/#{@query}"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  before(:each) do
    do_get @url
  end
  
  it "should check the database for an existing record" do
    PubmedQuery.should_receive(:find_by_query).with(@query).and_return(pubmed_queries(:biodiversity_informatics))
    do_get @url
  end
  
	
  it "should truncate the query in the page heading if it's really long" do
    pubmed_query = pubmed_queries(:long_query)
    do_get "/articles/#{pubmed_query.query}"
    doc = Hpricot(response.body)
    
    (doc/"span.query").inner_text.length.should > 0
		(doc/"span.query").inner_text.length.should < pubmed_query.query.length
  end

  it_should_behave_like "an article's 'show' page"
  
end

describe 'GET /articles/:id GIVEN a pubmed_query_id that exists in the database and is DONE Searching' do
  controller_name :articles
  fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  integrate_views
  
  before(:each) do
    @pubmed_query_id  = pubmed_queries(:biodiversity_informatics).id
    @query = pubmed_queries(:biodiversity_informatics).query
    @url = "/articles/#{@pubmed_query_id}"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
    
  it "should look up the record by ID in the database" do
    PubmedQuery.should_receive(:find).with(@pubmed_query_id.to_s).and_return(pubmed_queries(:biodiversity_informatics))
    do_get @url
  end

  it "should truncate the query in the page heading if it's really long" do
    pubmed_query = pubmed_queries(:long_query)
    do_get "/articles/#{pubmed_query.id}"
    doc = Hpricot(response.body)
    
    (doc/"span.query").inner_text.length.should > 0
		(doc/"span.query").inner_text.length.should < pubmed_query.query.length
  end
  
  it_should_behave_like "an article's 'show' page"
end

describe 'GET /articles/{pubmed_query_id}/status GIVEN a pubmed_query_id that is not done Searching' do
  controller_name :articles
  fixtures :pubmed_queries
  integrate_views

  before(:each) do
    @pubmed_query_id  = pubmed_queries(:still_searching).id
		@query = pubmed_queries(:still_searching).query
    @url = "/articles/#{@pubmed_query_id}/status"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  after(:each) do
    do_get @url
  end
  
  it "should ask the PubmedQuery if it's done yet" do
    @pmq = pubmed_queries(:still_searching)
    
    PubmedQuery.should_receive(:find).with( @pmq.id.to_s ).and_return( @pmq )
    @pmq.should_receive(:done?).and_return(:false)
  end
  

  it "should show the query in the articles text input" do
		do_get @url
    response.should have_tag('input#articles_q[value=?]', @query)
  end
  
  it "should truncate the query in the page heading if it's really long" do
    pubmed_query = pubmed_queries(:long_query_still_searching)
    do_get "/articles/#{pubmed_query.id}/status"
    doc = Hpricot(response.body)
    
    (doc/"span.query").inner_text.length.should < pubmed_query.query.length
  end
  

  it "should have a Javascript snippet that AJAX's the status message" do
    do_get @url
    response.should have_tag('script', /status_request = new Request\(\{url:".+#{@url}.js", method:'get'/)
    response.should have_tag('script', /status_request\.send\.periodical\(\d+, status_request\)/)
  end
  
  it "should also render in JS, JSON, and XML" do
    do_get @url, :js
    response.body.should == 'Searching'
    
    do_get @url, :json
    response.body.should == {:status => 'searching'}.to_json
    
    do_get @url, :xml
    response.body.should == "<status>searching</status>"
  end
end

describe 'GET /articles/{pubmed_query_id}/status GIVEN a pubmed_query_id that is done Searching' do
  controller_name :articles
  fixtures :pubmed_queries
  integrate_views
  
  before(:each) do
    @pubmed_query_id  = pubmed_queries(:biodiversity_informatics).id
    @url = "/articles/#{@pubmed_query_id}/status"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  before(:each) do
    do_get @url
  end
  
  it "should redirect to /articles/{pubmed_query_id} if a normal http request" do
    response.should redirect_to article_by_query_url( pubmed_queries(:biodiversity_informatics).query )
  end
  
  it "should render the text 'done' if it's an XHR" do
    do_xhr :get, @url
    response.body.should == 'done'
  end
end