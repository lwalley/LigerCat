require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlastQueriesController do
  describe 'GET /genes' do
    before(:each) do
      get :index
    end

    it "should render the 'intro' page with the genes tab selected" do
      response.should render_template("blast_queries/index")
    end
  end

  describe 'POST /genes' do
    before(:each) do
      Resque.stub!(:enqueue)
    end

    describe 'GIVEN a gene sequence that does not exist in the database' do
      before(:each) do
        @fasta_data = ">\nOMFGTHISSEQUENCEDOESNTEXISTINTHEDATABASE"
      end
  
      it "should check the database for an existing record" do
        BlastQuery.should_receive(:find_by_sequence).with(@fasta_data).and_return(nil)
        post :create, :q => @fasta_data
      end
  
      it "should create a new BlastQuery" do
        BlastQuery.should_receive(:create).with(:fasta_data => @fasta_data).and_return(mock_model(BlastQuery))
        post :create, :q => @fasta_data
      end
  
      it "should redirect the user to a status page for the query they just created" do
        post :create, :q => @fasta_data
        gene_id = assigns[:query].id
        response.should redirect_to( status_blast_query_path(gene_id) )
      end
    end

    describe 'GIVEN a gene sequence that exists in the database' do
      fixtures :blast_queries, :sequences, :blast_mesh_frequencies    
  
      before(:each) do
        @sequence = sequences(:an_amino_acid)
      end
  
      it "should check the database for an existing record" do
        BlastQuery.should_receive(:find_by_sequence).with(@sequence.fasta_data).and_return(blast_queries(:amino_acid_query))
        post :create, :q => @sequence.fasta_data
      end
  
      it "should redirect to the show page for that sequence" do
        post :create, :q => @sequence.fasta_data
        gene_id = blast_queries(:amino_acid_query).id
        response.should redirect_to( blast_query_path(gene_id) )
      end
    end
  end


  describe 'GET /blast_queries/:id' do  
    describe' GIVEN an :id that exists in the database and is DONE Blasting' do
      fixtures :blast_queries, :sequences, :blast_mesh_frequencies, :mesh_keywords  

      before(:each) do
        @blast_query  = blast_queries(:amino_acid_query)
      end
  
      it "should look up the record by ID in the database" do
        BlastQuery.should_receive(:find).with(@blast_query.id.to_s).and_return(@blast_query)
        get :show, :id => @blast_query.id
      end
    
      it "should render the show template" do
        get :show, :id => @blast_query.id
        response.rendered[:template].should == 'blast_queries/show.haml'
      end
    end
  
    describe' GIVEN an :id that exists in the database and is not finished Blasting' do
      fixtures :blast_queries, :sequences, :blast_mesh_frequencies, :mesh_keywords  

      before(:each) do
        @blast_query  = blast_queries(:still_blasting)
      end
  
      it "should look up the record by ID in the database" do
        BlastQuery.should_receive(:find).with(@blast_query.id.to_s).and_return(@blast_query)
        get :show, :id => @blast_query.id
      end
    
      it "should redirect to the status page for that query" do
        get :show, :id => @blast_query.id
        response.should redirect_to(status_blast_query_path(@blast_query))
      end
    end
  end


  describe 'GET /blast_queries/:id/status' do
      
    describe 'GIVEN an :id that is not done Blasting' do
      fixtures :blast_queries
    
      before(:each) do
        @blast_query = blast_queries(:still_blasting)
      end
  
      it "should ask the BlastQuery if it's done yet" do
        BlastQuery.should_receive(:find).with( @blast_query.id.to_s ).and_return( @blast_query )
        @blast_query.should_receive(:done?).and_return(:false)
        get :status, :id => @blast_query.id
      end

      it "should render the status template" do
        get :status, :id => @blast_query.id
        response.rendered[:template].should == 'blast_queries/status.haml'
      end
  
      it "should render the text 'done' if it's an XHR" do
        xhr :get, :status, :id => @blast_query.id
        response.body.should == @blast_query.state.to_s.titleize
      end
    end
  end
  
  describe 'GIVEN an :id that is done Blasting' do
    fixtures :blast_queries  
  
    before(:each) do
      @blast_query  = blast_queries(:amino_acid_query)
    end
  
    it "should redirect to /blast_queries/:id if a normal http request" do
      get :status, :id => @blast_query.id
      response.should redirect_to blast_query_url( @blast_query )
    end
  
    it "should render the text 'done' if it's an XHR" do
      xhr :get, :status, :id => @blast_query.id
      response.body.should == 'done'
    end
  end
  
  describe 'DELETE /genes/:id/cache' do 
    fixtures :blast_queries
  
    before :each do
      @query  = blast_queries(:amino_acid_query)
      ActionController::Base.perform_caching = true
    end
    
    after :each do
      ActionController::Base.perform_caching = false
      clear_cache(blast_query_path(@query))
    end
    
    
    it "should expire the cache" do
      # Sanity Check
      clear_cache(blast_query_path(@query))
      cached?(blast_query_path(@query)).should be_false, "Failed sanity check, something is whack with the tests"
      
      get :show, :id => @query.id
      cached?(blast_query_path(@query)).should be_true
            
      delete :cache, :id => @query.id
      cached?(pubmed_query_path(@query)).should be_false
    end
    
    it "should return HTTP 204" do
      delete :cache, :id => @query.id
      response.status.should == '204 No Content'
    end
  end
  
end


