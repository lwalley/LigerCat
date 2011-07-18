# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time
  before_filter :set_context

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'a74cc8e908877915f14f9f0014a9bfc7'
  self.allow_forgery_protection = false
  
  private 
  
  def set_context
    @context = controller_name    
  end
end
