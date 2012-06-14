class GenesController < ApplicationController
  caches_action :index
	
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
			cache_page 
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
