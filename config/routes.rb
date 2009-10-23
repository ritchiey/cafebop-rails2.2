ActionController::Routing::Routes.draw do |map|
  
  map.resources :menu_templates
  map.activate '/users/activate', :controller => 'users', :action => 'activate'
  map.resources :users
  map.resources :user_sessions
  map.register '/register', :controller=>:users, :action=>:new
  map.login '/login', :controller=>:user_sessions, :action=>:new
  map.logout '/logout', :controller=>:user_sessions, :action =>:destroy
  map.resources :claims, :member=>{:review=>:put, :confirm=>:put, :reject=>:put}

  map.resources :order_items
  # map.resources :menus
  map.resources :shops, :shallow=>true, :collection=>{:search=>:get} do |shops|
    shops.resources :item_queues, :member=>[:current_items]
    shops.resources :claims, :only=>[:create]
    shops.resources :orders, :shallow=>true, :member=>{:summary => :get, :new => :get, :create => :put, :pay_in_shop =>:put, :pay_paypal=> :put} do |orders|
      orders.resources :order_items, :member=>{:make=>:put}
    end
    shops.resources :menus, :shallow=>true do |menus|
      menus.resources :menu_items, :shallow=>true do |menu_items|
        menu_items.resources :sizes
        menu_items.resources :flavours
      end
    end
  end

  map.root :controller => "front", :action=>'index'

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

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

