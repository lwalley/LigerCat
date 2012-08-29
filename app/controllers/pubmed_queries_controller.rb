class PubmedQueriesController < ApplicationController
  helper_method  :query
  caches_page :index
  
  layout 'with_sidebar'
  
    
  # GET /articles
  def index
    render :layout => 'home'
  end
  
  # GET /articles/search
  # This is essentially a create method on a GET method
  def search
    redirect_to(pubmed_queries_path) and return if params[:q].blank?
    
    @query = Query.where(:type => ['PubmedQuery', 'BinomialQuery']).find_or_create_by_query(params[:q], PubmedQuery)

    redirect_to slug_pubmed_query_path(@query, @query.slug)
  end
  
  # GET /articles/:id
  def show
    @query ||= PubmedQuery.find(params[:id])
    
    if @query.done?
      @mesh_frequencies = @query.mesh_frequencies.order('mesh_keywords.name ASC').includes(:mesh_keyword)
      respond_to do |format|
        format.html do
          @publication_histogram = @query.publication_dates.to_histohash # Keeps histogram out of the cloud iframe thingy. TODO refactor the views so this hack isn't needed
          render :action => 'show'; cache_page
        end
        format.cloud { render :action => 'embedded_cloud', :layout => 'iframe'; cache_page }
      end
    else
      redirect_to status_pubmed_query_path(@query)
    end
  end
  
  # GET /eol/:taxon_concept_id
  def eol
    begin
      @query = EolTaxonConcept.includes(:query).find(params[:taxon_concept_id]).query
      show
    rescue ActiveRecord::RecordNotFound => e
      # 404 rendering. We want a really clean 404 for the eol clouds
      respond_to do |format|
        format.html  { render :file => "#{Rails.root}/public/404.html", :status => 404 }
        format.cloud { render :text => "", :status => 404 }
      end
    end
  end
  
  # GET /articles/:id/status
  # This is technically another resource, so probably some Rails Nazi would
  # tell me that it should be in another controller. But I just don't see the point.
  def status
    @query = PubmedQuery.find(params[:id])

    if @query.done? 
      return redirect_to slug_pubmed_query_path(@query, @query.slug) unless request.xhr?
    end
    
    @status = @query.humanized_state

    respond_to do |format|
      format.html #status.haml
      format.js   { render :text => @status.titleize }
      format.json do
        json = { code: @query.read_attribute(:state),
                 done: @query.done?,
                error: @query.error? }
                
        json[:template] = render_to_string(partial: 'shared/query_error') if @query.error?
        
        render :json => json.to_json
      end 
      format.xml  { render :xml => "<status>#{@status}</status>" }
    end
    
  end
  
  # DELETE /articles/:id/cache
  def cache
    query = PubmedQuery.find(params[:id])
    expire_page :action => :show
    expire_page :action => :show, :slug => query.slug
    render :nothing => true, :status => :no_content
  end
  
  
  private
  
  # query is a helper method that is used to put the query up in the <title>
  def query
    @query.query rescue nil
  end
end
