ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.resources :addresses
  map.resources :features
  map.resources :choices
  map.resources :discounts
  map.resources :quantity_prices
  map.resources :enquiries, :collection => { :thank_you => :get }
  map.resources :websites
  map.resources :orders, :collection => { :my => :get, :receipt => :get, :select_payment_method => :get, :purge_old_unpaid => :get }
  map.resources :products, :collection => { :google_data_feed => :get, :upload_google_data_feed => :get }
  map.resources :product_groups
  map.resources :product_group_placements
  map.resources :product_placements, :collection => { :move_up => :post, :move_down => :post }
  map.resources :forums
  map.resources :users, :collection => {:forgot_password => :get, :forgot_password_new => :get, :forgot_password_send => :post} do |user|
    user.resources :orders
  end
  
  map.new_topic 'topics/new/:forum_id', :controller => 'topics', :action => 'new'
  map.topic 'topics/show/:id', :controller => 'topics', :action => 'show'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'pages', :action => 'show', :slug => ''

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.page ':slug', :controller => 'pages', :action => 'show'
end
