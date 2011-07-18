class EolController < ApplicationController
  helper_method  :query
  
  # GET /articles/:id
  def show
    if @query = PubmedQuery.find_by_eol_taxa_id(params[:id])
      @mesh_frequencies = @query.pubmed_mesh_frequencies.find(:all, :include => :mesh_keyword, :order => 'mesh_keywords.name asc')
      respond_to do |format|
        format.html  do
          # TODO: this is a bit of a hack, to prevent the histograms from showing in eol clouds we need to rethink this later
          @publication_histogram = @query.publication_dates.to_histohash
          render 'articles/show'; cache_page
        end
        format.cloud { render :action => 'show', :layout => 'iframe'; cache_page }
      end
    else
      # 404 rendering. We want a really clean 404 for the eol clouds
      respond_to do |format|
        format.html  { render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 }
        format.cloud { render :text => "", :status => 404 }
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
end