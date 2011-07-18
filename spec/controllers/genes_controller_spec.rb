require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GenesController do
  describe "- route recognition" do
    it "GET /genes should generate params { :controller => 'genes', :action => 'new' }" do
      params_from(:get, "/genes").should == {:controller => "genes", :action => "new"}
    end
    
    it "POST /genes should generate params { :controller => 'genes', :action => 'create' }" do
      params_from(:post, "/genes").should == {:controller => "genes", :action => "create"}
    end
    
    it "GET /genes/123 should generate params { :controller => 'genes', :action => 'show', :id => '123' }" do
      params_from(:get, "/genes/123").should == {:controller => "genes", :action => "show", :id => '123'}
    end
    
    it "GET /genes/atcgatcg should generate params { :controller => 'genes', :action => 'create_or_show', :q => 'atcgatcg' }" do
      params_from(:get, "/genes/" + URI.escape(">\natcgatcg")).should == {:controller => "genes", :action => "create_or_show", :q => ">\natcgatcg"}
    end
    
    it "GET /genes/1234/status should generate params { :controller => 'genes', :action => 'status', :id => '1234' }" do
      params_from(:get, "/genes/1234/status").should == {:controller => "genes", :action => "status", :id => '1234'}
    end
    
    it "GET /genes/1234/status.json should generate params { :controller => 'genes', :action => 'status', :id => '1234', :format => 'json' }" do
      params_from(:get, "/genes/1234/status.json").should == {:controller => "genes", :action => "status", :id => '1234', :format => 'json'}
    end
  end
end

describe 'GET /genes' do
  controller_name find_controller_name(:get, '/genes')
  integrate_views

  before(:each) do
    do_get('/genes')
  end

  it "should render the 'intro' page with the genes tab selected" do
    response.should render_template("genes/new")
    response.should have_tag(".navigation li.genes.active")
  end

end


describe 'GET /genes/{gene_sequence} GIVEN a gene_sequence that does not exist in the database' do
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  

  before(:all) do
    @sequence = ">\nOMFGTHISSEQUENCEDOESNTEXISTINTHEDATABASE"
    @url = "/genes/#{URI.escape @sequence}"
  end
  
  before(:each) do
    # Mock to prevent BackgrounDRB server from actually running
    BlastWorker.stub!(:async_execute_search)
  end
  
  it "should check the database for an existing record" do
    BlastQuery.should_receive(:find_by_sequence).with(@sequence).and_return(nil)
    do_get @url
  end
  
  it "should create a new BlastQuery" do
    BlastQuery.should_receive(:create).with(:fasta_data => @sequence).and_return(mock_model(BlastQuery))
    do_get @url
  end
  
  it "should kick off a background worker" do
    BlastWorker.should_receive(:async_execute_search)
    do_get @url
  end
  
  it "should redirect the user to a status page for the query they just created" do
    do_get @url
    gene_id = assigns[:query].id
    response.should redirect_to("/genes/#{gene_id}/status")
  end
end

describe 'GET /genes/{gene_sequence} GIVEN a gene_sequence that exists in the database and is still Blasting' do
  fixtures :blast_queries, :sequences, :blast_mesh_frequencies  
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  
  
  before(:each) do
    @sequence = sequences(:still_blasting).fasta_data
    @url = "/genes/#{URI.escape @sequence}"
  end
  
  it "should check the database for an existing record" do
    BlastQuery.should_receive(:find_by_sequence).with(@sequence).and_return(blast_queries(:still_blasting))
    do_get @url
  end
  
  it "should redirect to the status page for that sequence" do
    do_get @url
    gene_id = blast_queries(:still_blasting).id
    response.should redirect_to("/genes/#{gene_id}/status")
  end
end

describe "a gene's 'show' page", :shared => true do
  it "should show the tag cloud for that sequence" do
    do_get @url
    response.should have_tag('ol.keyword_cloud') do
      with_tag('li a', 'Humans')  # these mesh terms are bogus for this blast_query, but are set up in the fixtures
      with_tag('li a', 'Molecular Sequence Data')
    end
  end
  
  it "should show the sequence in the genes textarea" do
    do_get @url
    response.should have_tag('textarea#genes_q', /#{@sequence.to_a.last}/)
  end
  
  it "should have a form where the user can BLAST their sequence" do
    do_get @url
    response.should have_tag('form[action=?]', 'http://blast.ncbi.nlm.nih.gov/Blast.cgi')
    response.should have_tag('input[name=QUERY][type=hidden][value$=?]', @sequence.to_a.last)
  end
end

describe 'GET /genes/{gene_sequence} GIVEN a gene_sequence that exists in the database and is DONE Blasting' do
  fixtures :blast_queries, :sequences, :blast_mesh_frequencies, :mesh_keywords
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  
  
  before(:each) do
    setup_fixtures # Lame.
    @sequence = sequences(:an_amino_acid).fasta_data
    @url = "/genes/#{URI.escape @sequence}"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  before(:each) do
    do_get @url
  end
  
  it "should check the database for an existing record" do
    BlastQuery.should_receive(:find_by_sequence).with(@sequence).and_return(blast_queries(:amino_acid_query))
    do_get @url
  end
  
  it_should_behave_like "a gene's 'show' page"
end

describe 'GET /genes/n GIVEN a blast_query_id that exists in the database and is DONE Blasting' do
  fixtures :blast_queries, :sequences, :blast_mesh_frequencies, :mesh_keywords
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  
  
  before(:each) do
    setup_fixtures # Lame.
    @blast_query_id  = blast_queries(:amino_acid_query).id
    @sequence = sequences(:an_amino_acid).fasta_data
    @url = "/genes/#{@blast_query_id}"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  it "should look up the record by ID in the database" do
    BlastQuery.should_receive(:find).with(@blast_query_id.to_s).and_return(blast_queries(:amino_acid_query))
    do_get @url
  end
  
  it_should_behave_like "a gene's 'show' page"
end


describe 'GET /genes/{blast_query_id}/status GIVEN a blast_query_id that is not done Blasting' do
  fixtures :blast_queries
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  

  before(:each) do
    @blast_query_id  = blast_queries(:still_blasting).id
    @url = "/genes/#{@blast_query_id}/status"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  

  after(:each) do
    do_get @url
  end
  
  it "should ask the BlastQuery if it's done yet" do
    @bq = blast_queries(:still_blasting)
    
    BlastQuery.should_receive(:find).with( @bq.id.to_s ).and_return( @bq )
    @bq.should_receive(:done?).and_return(:false)
  end
  

  it "should have a Javascript snippet that refreshes the status message" do
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

describe 'GET /genes/{blast_query_id}/status GIVEN a blast_query_id that is done Blasting' do
  fixtures :blast_queries
  integrate_views
  controller_name find_controller_name(:get, '/genes')
  
  
  before(:each) do
    setup_fixtures
    @blast_query_id  = blast_queries(:amino_acid_query).id
    @url = "/genes/#{@blast_query_id}/status"
    @controller_class_name = find_controller_class_name(:get, @url)
  end
  
  before(:each) do
    do_get @url
  end
  
  it "should redirect to /genes/{blast_query_id} if a normal http request" do
    response.should redirect_to gene_url( blast_queries(:amino_acid_query) )
  end
  
  it "should render the text 'done' if it's an XHR" do
    do_xhr :get, @url
    response.body.should == 'done'
  end
end



