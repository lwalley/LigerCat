class SelectionsController < ApplicationController
  before_filter :find_selections
  before_filter :split_and_integerize_multiple_journals, :only => [:create, :destroy_some]

  # POST /selections
  def create
    # @journal_ids set by before_filter
    session[:selections] = (session[:selections] + @journal_ids).uniq

    respond_to do |format|
      format.js   { head :created }
      format.xml  { head :created }
    end
  end

  # DELETE /selections/:id
  def destroy
    session[:selections].delete(params[:id].to_i)
    respond_to do |format|
      flash[:notice] = "Journal #{params[:id].to_i} deleted from selections"
      format.js   { head :ok }
      format.xml  { head :ok }
    end
  end

  # DELETE /selections/destroy_some
  # TODO: We could possibly just pass multiple id's into DELETE /selections/:id?
  def destroy_some
    # @journal_ids set by before_filter
    session[:selections] = session[:selections] - @journal_ids

    respond_to do |format|
      format.html { render :nothing => true, :status => :no_content }
      format.js   { head :created, :location => selection_url(@journal_id) }
      format.xml  { head :created, :location => selection_url(@journal_id) }
    end
  end

  # DELETE/selections/destroy_all
  def destroy_all
    session[:selections] = []
    respond_to do |format|
      format.html { render :nothing => true, :status => :no_content }
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
