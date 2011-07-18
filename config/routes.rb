ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  map.connect '/journals/error', :controller => 'journals', :action => 'error'

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  map.resources :journals
  map.resources :eol, :only => :show
  map.resources :selections, :collection => {:destroy_all => :delete, :destroy_some => :delete}
  map.resource  :pubmed_count
  map.resources :subject_terms
  map.resources :journal_queries

  # Custom routes for  articles
  map.new_article '/articles', :controller => 'articles', :action => 'new',    :conditions => { :method => :get }
  map.articles    '/articles', :controller => 'articles', :action => 'create', :conditions => { :method => :post }
  map.article     '/articles/:id', :id => /\d+/, :controller => 'articles', :action => 'show', :conditions => { :method => :get }
  map.formatted_article '/articles/:id.:format', :id => /\d+/, :controller => 'articles', :action => 'show', :conditions => { :method => :get }
  map.article_status '/articles/:id/status', :id => /\d+/, :controller => 'articles', :action => 'status', :conditions => { :method => :get }
  map.formatted_article_status '/articles/:id/status.:format', :id => /\d+/, :controller => 'articles', :action => 'status', :conditions => { :method => :get }
  map.article_by_query '/articles/:q', :q => /.*/, :controller => 'articles', :action => 'create_or_show', :conditions => { :method => :get }
  
  

  # Custom routes for genes
  map.new_gene '/genes', :controller => 'genes', :action => 'new', :conditions => { :method => :get }
  map.genes    '/genes', :controller => 'genes', :action => 'create', :conditions => { :method => :post }
  map.gene     '/genes/:id', :id => /\d+/, :controller => 'genes', :action => 'show', :conditions => { :method => :get }
  map.gene_status '/genes/:id/status', :id => /\d+/, :controller => 'genes', :action => 'status', :conditions => { :method => :get }
  map.formatted_gene_status '/genes/:id/status.:format', :id => /\d+/, :controller => 'genes', :action => 'status', :conditions => { :method => :get }
  map.gene_by_query '/genes/:q', :q => /.*/, :controller => 'genes', :action => 'create_or_show', :conditions => { :method => :get }
  


  # These routes are called by our slick-ass helper ApplicationHelper#context_home_url
  map.journals_home '/journals', :controller => 'journals', :action => 'index'
  map.articles_home '/articles', :controller => 'articles', :action => 'new'
  map.genes_home    '/genes',    :controller => 'genes',    :action => 'new'


  map.connect '/about', :controller => 'static', :action => 'about', :conditions =>{:method => :get}
  map.send_feedback '/about', :controller => 'static', :action => 'send_feedback', :conditions => {:method => :post}
  map.connect '/about.html', :controller => 'static', :action => 'about'
  
  map.connect '/:q', :controller => 'journals', :action => 'index'

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "articles", :action => 'new'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
