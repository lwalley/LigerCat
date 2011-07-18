class JournalQueriesController < ApplicationController
  def show
    @query = JournalQuery.find(params[:id])
     
    if @query.done?
      redirect_url = url_for :controller => 'journals', :action => 'index', :q => @query.query
      
      if request.xhr?
        render :text => 'done'
      else
        redirect_to redirect_url
      end

    else
      @status = 'searching' #TODO This used to get the status from Backgroundrb. Haven't set that up w/ Workling yet
      
      respond_to do |format|
        format.html #show.haml
        format.js   { render :text => @status.titleize }
        format.json { render :json => {:status => @status}.to_json }
        format.xml  { render :xml => "<status>#{@status}</status>" }
      end
    end
  end
  
  private
  
  def set_context
    @context = 'journals'
  end
end
