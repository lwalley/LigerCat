require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe 'GET /articles' do
  controller_name find_controller_name(:get, '/articles')

  it "should render the index template" do
    get :index
    response.rendered[:template].should == 'articles/index.haml'
  end

end

describe 'GET /articles/?q={pubmed_query} GIVEN a pubmed_query that does not exist in the database' do
  controller_name :articles
  
  before(:all) do
    @query = "Biology"
  end
  
  before(:each) do
    Resque.stub!(:enqueue) # Prevent any potential work being done
  end
  
  it "should check the database for an existing record" do
    PubmedQuery.should_receive(:find_by_query).with(@query).and_return(nil)
    get :index, :q => @query
  end
  
  it "should create a new PubmedQuery" do
    PubmedQuery.should_receive(:create).with(:query => @query).and_return(mock_model(PubmedQuery))
    get :index, :q => @query
  end
  
  it "should redirect the user to a status page for the query they just created" do
    get :index, :q => @query
    response.should redirect_to( status_article_path(assigns[:query].id) )
  end
end

describe 'GET /articles/?q={pubmed_query} GIVEN a pubmed_query that exists in the database' do
  controller_name :articles
  fixtures :pubmed_queries
  
  
  before(:each) do
    @query = pubmed_queries(:biodiversity_informatics)
  end
  
  it "should check the database for an existing record" do
    PubmedQuery.should_receive(:find_by_query).with(@query.query).and_return(@query)
    get :index, :q => @query.query
  end
  
  it "should redirect the user to the show page for the query" do
    get :index, :q => @query.query
    response.should redirect_to( slug_article_path(@query.id, @query.slug) )
  end
end


describe 'GET /articles/:id GIVEN a PubmedQuery that exists in the database and is still Searching' do
  controller_name :articles
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
    response.should redirect_to( status_article_path(pubmed_queries(:still_searching).id) )
  end
end

describe 'GET /articles/:id GIVEN a PubmedQuery that is DONE Searching' do
  controller_name :articles
  fixtures :pubmed_queries, :pubmed_mesh_frequencies, :mesh_keywords
  
  it "should find the query in the database" do
    query = pubmed_queries(:biodiversity_informatics)
    get :show, :id => query.id
    assigns[:query].should == query
  end

end


describe 'GET /articles/:id/status' do
  controller_name :articles
  
  describe 'GIVEN a PubmedQuery that is done Searching' do
    fixtures :pubmed_queries
  
    before(:each) do
      @query  = pubmed_queries(:biodiversity_informatics)
    end
  
    it "should redirect to /articles/{pubmed_query_id} if a normal http request" do
      get :status, :id => @query.id
      response.should redirect_to slug_article_path( @query.id, @query.slug )
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
      response.rendered[:template].should == 'articles/status.haml'
    end
  
    it "should render the text 'done' if it's an XHR" do
      xhr :get, :status, :id => @query.id
      response.body.should == @query.state.to_s.titleize
    end
    
  end
end