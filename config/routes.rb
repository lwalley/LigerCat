ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  map.resources :journals, :only => [:index, :show]
  map.resources :eol, :only => :show
  map.resources :selections, :only => [:create, :destroy], :collection => {:destroy_all => :delete, :destroy_some => :delete}
  map.resource  :pubmed_count, :only => [:show]
  map.resources :journal_queries, :only => [:show]
  map.resources :articles, :only => [:index, :show], :member => {:status => :get}, :collection => {:search => :get}
  map.slug_article '/articles/:id/:query', :controller => 'articles', :action => 'show'
  map.resources :genes, :only => [:index, :create, :show], :member => {:status => :get}

  map.about '/about' ,:controller => 'static', :action => 'about'

  map.root :controller => "articles", :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
