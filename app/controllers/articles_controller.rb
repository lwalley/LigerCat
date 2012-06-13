class ArticlesController < ApplicationController
  helper_method  :query
  # FIXME: Make this work for articles home page caches_action :new
  
  # GET /articles
  def index
    create_or_show and return unless params[:q].blank?
    render :layout => 'home'
  end
  
  # GET /articles/:id
  def show
    @query = PubmedQuery.find(params[:id])
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
      redirect_to status_article_path(@query)
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
        redirect_to slug_article_path(@query, @query.slug)
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
    @context = 'articles'
  end
  
  def query
    @query.query rescue nil
  end

  def create_or_show
    if @query = PubmedQuery.find_by_query(params[:q])
      redirect_to slug_article_path(@query, @query.slug)
    else
      create
    end
  end

  # This is called from create_or_show, there is not a POST /articles so we make it private.
  def create
    @query = PubmedQuery.create(:query => params[:q])    
    redirect_to status_article_path(@query)
  end
end
