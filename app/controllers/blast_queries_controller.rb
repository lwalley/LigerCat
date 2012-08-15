class BlastQueriesController < ApplicationController
  caches_action :index
	
  # GET /genes
  def index
    render :layout => 'home'
  end
  
  # POST /genes
  def create
    if @query = BlastQuery.find_by_sequence(params[:q])
      redirect_to blast_query_path(@query)
    else
      @query = BlastQuery.create(:fasta_data => params[:q])
      redirect_to status_blast_query_path(@query)
    end
  end
  
  # GET /genes/:id
  def show
    @query ||= BlastQuery.find(params[:id])
    if @query.done?
      @mesh_frequencies = @query.mesh_frequencies.order('mesh_keywords.name ASC').includes(:mesh_keyword)
      @publication_histogram = @query.publication_dates.to_histohash
      render :action => 'show'
			cache_page 
    else
      redirect_to status_blast_query_path(@query)
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
        redirect_to blast_query_path(@query)
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
  
  # DELETE /genes/:id/cache
  def cache
    query = BlastQuery.find(params[:id])
    expire_page :action => :show
    render :nothing => true, :status => :no_content
  end
  
end
