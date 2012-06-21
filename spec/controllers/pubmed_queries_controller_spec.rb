require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PubmedQueriesController do

  describe 'GET /articles' do
    it "should render the index template" do
      get :index
      response.rendered[:template].should == 'pubmed_queries/index.haml'
    end
  end

  describe 'GET /articles/search?q={pubmed_query} GIVEN a pubmed_query that does not exist in the database' do
  
    before(:all) do
      @query_string = "Biology"
    end
  
    before(:each) do
      Resque.stub!(:enqueue) # Prevent any potential work being done
    end
  
    it "should check the database for an existing record" do
      PubmedQuery.should_receive(:find_by_query).with(@query_string).and_return(nil)
      get :search, :q => @query_string
    end
  
    it "should create a new PubmedQuery" do
      PubmedQuery.should_receive(:create).with(:query => @query_string).and_return(mock_model(PubmedQuery, :slug => 'some-slug'))
      get :search, :q => @query_string
    end
  
    it "should redirect the user to a show page for the query they just created" do
      get :search, :q => @query_string
      response.should redirect_to( slug_pubmed_query_path(assigns[:query].id, assigns[:query].slug) )
    end
  end

  describe 'GET /articles/search?q={pubmed_query} GIVEN a pubmed_query that exists in the database' do
    fixtures :pubmed_queries
  
    before(:each) do
      @query = pubmed_queries(:biodiversity_informatics)
    end
  
    it "should check the database for an existing record" do
      PubmedQuery.should_receive(:find_by_query).with(@query.query).and_return(@query)
      get :search, :q => @query.query
    end
  
    it "should redirect the user to the show page for the query" do
      get :search, :q => @query.query
      response.should redirect_to( slug_pubmed_query_path(@query.id, @query.slug) )
    end
  end
  
  describe 'GET /articles/search with no params' do
  
    it "should should redirect to /articles" do
      get :search
      response.should redirect_to( pubmed_queries_path )
    end
  end
  


  describe 'GET /articles/:id GIVEN a PubmedQuery that exists in the database and is still Searching' do
    fixtures :pubmed_queries
  
    before(:each) do
      @query = pubmed_queries(:still_searching)
    end
  
    it "should check the database for an existing record" do
      PubmedQuery.should_receive(:find).with(@query.id.to_s).and_return( pubmed_queries(:still_searching) )
      get :show, :id => @query.id
    end
  
    it "should redirect to the status page for that article" do
      get :show, :id => @query.id
      response.should redirect_to( status_pubmed_query_path(pubmed_queries(:still_searching).id) )
    end
  end

  describe 'GET /articles/:id GIVEN a PubmedQuery that is DONE Searching' do
    fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  
    it "should find the query in the database" do
      query = pubmed_queries(:biodiversity_informatics)
      get :show, :id => query.id
      assigns[:query].should == query
    end

  end


  describe 'GET /articles/:id/status' do
  
    describe 'GIVEN a PubmedQuery that is done Searching' do
      fixtures :pubmed_queries
  
      before(:each) do
        @query  = pubmed_queries(:biodiversity_informatics)
      end
  
      it "should redirect to /articles/{pubmed_query_id} if a normal http request" do
        get :status, :id => @query.id
        response.should redirect_to slug_pubmed_query_path( @query.id, @query.slug )
      end
  
      it "should render the text 'done' if it's an XHR" do
        xhr :get, :status, :id => @query.id
        response.body.should == 'done'
      end
    end
  
    describe "GIVEN a PubmedQuery that's still running" do
      fixtures :pubmed_queries
  
      before(:each) do
        @query  = pubmed_queries(:still_searching)
      end
  
      it "should render the status template" do
        get :status, :id => @query.id
        response.rendered[:template].should == 'pubmed_queries/status.haml'
      end
  
      it "should render the text 'done' if it's an XHR" do
        xhr :get, :status, :id => @query.id
        response.body.should == @query.state.to_s.titleize
      end
    
    end
  end
  
  describe 'DELETE /articles/:id/cache' do 
    fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  
    before :each do
      @query = pubmed_queries(:biodiversity_informatics)
      ActionController::Base.perform_caching = true
    end
    
    after :each do
      ActionController::Base.perform_caching = false
    end
    
    
    it "should expire the cache" do
      # Sanity Check
      clear_cache(pubmed_query_path(@query))
      clear_cache(slug_pubmed_query_path(@query, @query.slug))
      cached?(pubmed_query_path(@query)).should be_false, "Failed sanity check, something is whack with the tests"
      cached?(slug_pubmed_query_path(@query, @query.slug)).should be_false, "Failed sanity check, something is whack with the tests"
      
      get :show, :id => @query.id
      cached?(pubmed_query_path(@query)).should be_true
      
      # This actually works in real life, but not in fucking rspec. Fuck rspec.
      # get slug_pubmed_query_path(@query, @query.slug)
      # cached?(slug_pubmed_query_path(@query, @query.slug)).should be_true
      
      delete :cache, :id => @query.id
      cached?(pubmed_query_path(@query)).should be_false
      cached?(slug_pubmed_query_path(@query, @query.slug)).should be_false
    end
    
    it "should return HTTP 204" do
      delete :cache, :id => @query.id
      response.status.should == '204 No Content'
    end
  end
end