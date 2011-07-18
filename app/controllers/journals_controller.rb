class JournalsController < ApplicationController
  include Sortable
  helper SortableHelpers

  before_filter :reset_session_from_ids, :only => :show
  before_filter :search_if_params_q, :only => :index # Before filter to call #search if there are query params, which allows us to do page caching on #index
  
  caches_action :show, :index
  
  before_filter :load_selections_from_session, :only => :show
  before_filter :set_search_title, :only  => :index
  
  def index
    # searching GET /journals?q=search_query also gets routed here, but is handled by a before_filter.
    # This is done to allow us to do page caching on this action
    render :layout => 'home'
  end
  
  def show
    ids = params[:id].split(';')
    @journals = Journal.find(ids)
		@selections = @journals
    @mesh_frequencies = JournalMeshFrequency.find_frequencies_for_journals(ids)
    @text_frequencies = JournalTextFrequency.find_frequencies_for_journals(ids)
  end
  
  def auto_complete_for_expanded_journal_keyword
    auto_complete_responder_for_expanded_journal_keywords params[:q]
  end
  
  # This is used to test the ExceptionNotification plugin/ActionMailer configuration on the server
  def error
    begin
      raise RuntimeError, "Generating an error"  
    rescue Exception => e
      ExceptionNotifier.deliver_custom_notification("Exception in JournalWorker#execute_search", e)
      raise e
    end
  end
  
  private
  
  
  # Before filter to call #search if there are query params.
  # This allows us to do page caching on #index
  def search_if_params_q
    if params[:q].blank?
      true
    else
      search
    end
  end
  
  
  # We do fragment caching here so that we can keep the "selected journals" panel, which is populated
  # from the session, in the correct state
  def search
    load_selections_from_session # This should be done in a filter, but is not to get optimum performance out of our caching
    
    sortable :alphabetical, 'journals.title ASC'
    sortable :search_term,  'search_term_score DESC, journals.title ASC', :default => true
    sortable :mesh_rank,    'mesh_score DESC, journals.title ASC'
    sortable :text_rank,    'text_score DESC, journals.title ASC'
    
    if fragment_exist?({:action => 'search', :query => params[:q].downcase, :page => params[:page] || 1 })
      render :action => 'search' 
    else
      
      @query = JournalQuery.find_by_query(params[:q].downcase)

      if @query && @query.done?
        @journals = @query.journals.paginate(:page => params[:page], 
                                             :per_page => 50,
                                             :order => sortable_clause) 
        @start = @journals.offset + 1
            
        render :action => 'search' 
      else
        @query ||= JournalQuery.create(:query => params[:q].downcase)
        redirect_to journal_query_url(@query)
      end
    end
  end
  
  # Resets the session based on the IDs that came in through params.
  # 
  # This is a semi-hack required to 
  #   (a) keep the session in the correct state while
  #   (b) allowing us to do as much caching as we can
  def reset_session_from_ids
		session[:selections] = params[:id].split(';').map{ |id| id.to_i }
  end
  
  def load_selections_from_session
    unless session[:selections].blank?
      @selections = Journal.find(session[:selections])
      @selected_ids = Hash[ *@selections.map{|j| [j.id, true] }.flatten ]
      @all_journals_are_selected = true # set to false by our helper, which has to loop through all the journals and selections anyways
    end
  end
  
  def set_search_title
    unless params[:q].blank?
      @body_id = 'journals_search'
      @title   = params[:q] + ' - LigerCat'
    end
  end
  
  def auto_complete_responder_for_expanded_journal_keywords(value)
    find_options = { 
      :conditions => [ "LOWER(name) LIKE ?", '%' + value.downcase + '%' ], 
      :order => "name ASC",
      :limit => 10 }
    
    @items = ExpandedJournalKeyword.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end
end