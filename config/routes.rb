ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  map.resources :journals, :only => [:index, :show]
  map.resources :eol, :only => :show
  map.resources :selections, :only => [:create, :destroy], :collection => {:destroy_all => :delete, :destroy_some => :delete}
  map.resource  :pubmed_count, :only => [:show]
  map.resources :journal_queries, :only => [:show]
  map.resources :pubmed_queries, :as => :articles, :only => [:index, :show], :member => {:status => :get, :cache => :delete}, :collection => {:search => :get}
  map.slug_pubmed_query '/articles/:id/:slug', :controller => 'pubmed_queries', :action => 'show'
  map.resources :blast_queries, :as => :genes, :only => [:index, :create, :show], :member => {:status => :get, :cache => :delete}

  map.about '/about' ,:controller => 'static', :action => 'about'

  map.root :controller => "pubmed_queries", :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
