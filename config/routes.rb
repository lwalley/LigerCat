Ligercat::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  resource  :pubmed_count, :only => [:show]

  resources :pubmed_queries, :path => 'articles', :only => [:index, :show] do
    collection do
      get 'search'
    end

    member do
      get 'status'
      delete 'cache'
    end
  end
  # Redirect legacy requests for /articles/:query_string
  # Make sure this route comes after any named articles routes e.g. articles/search or articles/status
  match '/articles/:string' => 'pubmed_queries#legacy_redirect', :via => :get, :constraints => { :string => %r|[^/]*?[^/0-9][^/]*| }

  resources :blast_queries, :path => 'genes', :only => [:index, :create, :show] do
    member do 
      get 'status'
      delete 'cache'
    end
  end
  
  match '/eol/:taxon_concept_id' => 'pubmed_queries#eol'
  match '/articles/:id/:slug' => 'pubmed_queries#show', :as => :slug_pubmed_query
  match '/about' => 'static#about', :as => :about

  root :to => 'pubmed_queries#index'
end
