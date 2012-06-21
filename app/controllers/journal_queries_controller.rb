class JournalQueriesController < ApplicationController
  # GET /journals?q=
  def show
    @query = JournalQuery.find(params[:id])
     
    if @query.done?
      redirect_url = journals_url(:q => @query.query)
      
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
  

end
