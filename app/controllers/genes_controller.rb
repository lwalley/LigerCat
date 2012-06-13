class GenesController < ApplicationController
  # Whoa Nelly. This allows us to action cache the genes "home" page
  # in addition to the mesh cloud of a specific gene, all from one action.
  # The two are kept separate by appending the gene query key onto the name of 
  # the action.
  #
  # This is in addition to the page caching in #show. The approach used in ArticlesController
  # to use redirects and page caching throughout don't work here because the sequence strings are so long
  caches_action :new, :cache_path => Proc.new { |controller|
    controller.params[:q] ?
      controller.send(:genes_url) + "_#{BlastQuery.create_query_key(controller.params[:q])}" :
      controller.send(:genes_url)
  }
	
  # GET /genes
  def index
    render :layout => 'home'
  end
  
  # POST /genes
  def create
    if @query = BlastQuery.find_by_sequence(params[:q])
      redirect_to gene_path(@query)
    else
      @query = BlastQuery.create(:fasta_data => params[:q])
      redirect_to status_gene_path(@query)
    end
  end
  
  # GET /genes/:id
  def show
    @query ||= BlastQuery.find(params[:id])
    if @query.done?
      @mesh_frequencies = @query.blast_mesh_frequencies.find(:all, :include => :mesh_keyword, :order => 'mesh_keywords.name asc')
      @publication_histogram = @query.publication_dates.to_histohash
      render :action => 'show'
			cache_page unless params[:id].blank? # page cache only urls in the form of /genes/123, not ones coming in from create_or_show
    else
      redirect_to status_gene_path(@query)
    end
  end
  
  # GET /genes/:id/status
  # This is technically another resource, so probably some Rails Nazi would
  # tell me that it should be in another controller. But I just don't see the point.
  def status
    @query = BlastQuery.find(params[:id])

    if @query.done?
      if request.xhr?
        render :text => 'done'
      else
        redirect_to gene_path(@query)
      end
    else
      @status = @query.humanized_state

      respond_to do |format|
        format.html #status.haml
        format.js   { render :text => @status.titleize }
        format.json { render :json => {:status => @status}.to_json }
        format.xml  { render :xml => "<status>#{@status}</status>" }
      end
    end
  end
  
  private
  def set_context
    @context = 'genes'
  end
end
