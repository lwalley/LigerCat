class SelectionsController < ApplicationController
  before_filter :find_selections
  before_filter :split_and_integerize_multiple_journals, :only => [:create, :destroy_some]
  
  def index
    @selections = Journal.find(session[:selections])
  end

  def create
    # @journal_ids set by before_filter
    session[:selections] = (session[:selections] + @journal_ids).uniq
    
    respond_to do |format|        
      format.html do
        flash[:notice] = "Journal #{@journal_id} added to selections";
        redirect_to selections_url
      end
      
      format.js   { head :created, :location => selection_url(@journal_id) }
      format.xml  { head :created, :location => selection_url(@journal_id) }
    end
  end
  
  def show
    redirect_to journal_path(params[:id].to_i)
  end
  
  def destroy
    session[:selections].delete(params[:id].to_i)
    respond_to do |format|
      flash[:notice] = "Journal #{params[:id].to_i} deleted from selections"
      format.html { redirect_to selections_url }
      format.js   { head :ok }
      format.xml  { head :ok }
    end
  end
  
  def destroy_some
    # @journal_ids set by before_filter
    session[:selections] = session[:selections] - @journal_ids
    
    respond_to do |format|        
      format.html do
        flash[:notice] = "Journal #{@journal_id} removed from selections";
        redirect_to selections_url
      end
      
      format.js   { head :created, :location => selection_url(@journal_id) }
      format.xml  { head :created, :location => selection_url(@journal_id) }
    end
  end
  
  def destroy_all
    session[:selections] = []
    respond_to do |format|
      flash[:notice] = "Deleted all selections"
      format.html { redirect_to selections_url }
      format.js   { head :ok }
      format.xml  { head :ok }
    end
  end
  
  
  
  private
  def find_selections
    session[:selections] ||= []
  end
  
  def split_and_integerize_multiple_journals
    @journal_ids = params[:journal_id].split(';').map{|id| id.to_i }
  end
end
