class ArticlesController < ApplicationController
  before_filter :redirect_if_searching, :only => :new
  helper_method  :query
  caches_action :new
  
  # GET /articles
  # NOTE that a before_filter redirects GET /articles?q=my_search_query to GET /articles/my_search_query
  # This is done in a before_filter to let us do action_caching on #new, and page_caching on #show
  def new
    render :layout => 'home'
  end
  
  # GET /articles/:q
  def create_or_show
    if @query = PubmedQuery.find_by_query(params[:q])
      show
    else
      create
    end
  end
  
  # POST /articles
  def create
    @query = PubmedQuery.create(:query => params[:q])    
    redirect_to article_status_url(@query)
  end
  
  # GET /articles/:id
  def show
    @query ||= PubmedQuery.find(params[:id])
    if @query.done?
      @mesh_frequencies = @query.pubmed_mesh_frequencies.find(:all, :include => :mesh_keyword, :order => 'mesh_keywords.name asc')      
      respond_to do |format|
          format.html do
            @publication_histogram = @query.publication_dates.to_histohash # Keeps histogram out of the cloud iframe thingy. TODO refactor the views so this hack isn't needed
            render :action => 'show'; cache_page
          end
          format.cloud { render :action => 'embedded_cloud', :layout => 'iframe'; cache_page }
        end
        
      cache_page
    else
      redirect_to article_status_url(@query)
    end
  end
  
  # GET /articles/:id/status
  # This is technically another resource, so probably some Rails Nazi would
  # tell me that it should be in another controller. But I just don't see the point.
  def status
    @query = PubmedQuery.find(params[:id])

    if @query.done?
      if request.xhr?
        render :text => 'done'
      else
        redirect_to article_by_query_url(@query.query)
      end
    else
      @status = 'searching' #TODO This used to get the status from Backgroundrb. Haven't set that up w/ Workling yet

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
    @context = 'articles'
  end
  
  def query
    @query.query rescue nil
  end

  # Redirects GET /articles?q=my_search_query to GET /articles/my_search_query
  # This is done in a before_filter to let us do action_caching on #new, and page_caching on #show
  def redirect_if_searching
    if params.has_key? :q
      redirect_to article_by_query_url params[:q] 
    else
      true
    end
  end
end
