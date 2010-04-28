ActionController::Routing::Routes.draw do |map|

  map.resources :payment_notifications, :only=>[:create]
  map.resources :password_resets

  map.resources :operating_times
  map.resources :cuisines, :collection=>{:import_form=>:get, :import=>:post}

  
  map.dashboard '/dashboard', :controller=>'dashboard', :action=>'show'
  map.resources :menu_templates
  map.activate '/users/activate', :controller => 'users', :action => 'activate'
  map.resources :users, :shallow=>true, :member=>{:activation_sent=>:get, :activate_invited=>:put} do |users|
    users.resources :work_contracts
    users.resources :friendships, :only=>[:new, :create, :destroy]
  end
  map.resources :user_sessions
  map.register '/register', :controller=>:users, :action=>:new
  map.signup '/signup', :controller=>:users, :action=>:new
  map.login '/login', :controller=>:user_sessions, :action=>:new
  map.not_me '/not_me', :controller=>:user_sessions, :action=>:not_me
  map.logout '/logout', :controller=>:user_sessions, :action =>:destroy
  
  map.resources :orders, :collection=>{:accept=>:get, :decline=>:get}
  map.resources :order_items  

  map.resources :menus, :only=>[:new, :create, :index], # for generic menus
    :collection=>{:import=>:get, :import_csv=>:post}

  map.resources :queued_orders, :only=>[:show], :member=>{:cancel=>:put, :no_show=>:put, :deliver => :put, :make_all_items=>:put}
  map.resources :queued_order_items, :only=>[:show],
    :member=>{:make=>:put},
    :collection=>{:make_all=>:put}

  map.with_options(:conditions => {:subdomain => /.+/}) do |shop|
    shop.edit "edit", :controller=>'shops', :action=>'edit'
    shop.refund_policy_for "refund_policy", :controller=>'shops', :action=>'edit'

    shop.resources :operating_times
    shop.resources :item_queues, :member=>{:current_items=>:get, :stop=>:put, :start=>:put}
    shop.resources :customer_queues, :member=>{:current_orders=>:get, :stop=>:put, :start=>:put}
    shop.resources :past_orders
    shop.resources :orders, :shallow => true, :member => {
        :status_of_pending => :get,
        :status_of_queued => :get,
        :summary => :get,
        :new => :get,
        :create => :put,
        :place => :put,
        :cancel_paypal => :get,
        :invite=>:get,
        :send_invitations => :put,
        :confirm => :put,
        :close=>:put,
        :closed=>:get
        } do |orders|
      orders.resources :order_items, :member=>{:make=>:put}
    end
    shop.resources :menus, :shallow=>true, :member=>{:reorder_menu_items=>:post},
      :collection=>{:import=>:get, :import_csv=>:post} do |menus|
      menus.resources :menu_items, :shallow=>true, :member=>{:reorder_flavours=>:post, :reorder_sizes=>:post} do |menu_items|
        menu_items.resources :sizes
        menu_items.resources :flavours
      end
    end 
  end

  map.resources :shops, :shallow=>true,
    :collection=>{
      :search=>:get,
      :import_form=>:get,
      :import=>:get,
      :cuisineless=>:get,
      :guess_cuisines_for=>:put
      },
    :member=>{       
      :refund_policy_for=>:get,
      :reorder_menus=>:post,
      :reorder_item_queues=>:post,
      :reorder_operating_times=>:post,
      } do |shops|
    shops.resources :operating_times
    shops.resources :item_queues, :member=>{:current_items=>:get, :stop=>:put, :start=>:put}
    shops.resources :customer_queues, :member=>{:current_orders=>:get, :stop=>:put, :start=>:put}
    shops.resources :past_orders
    shops.resources :orders, :shallow => true, :member => {
        :status_of_pending => :get,
        :status_of_queued => :get,
        :summary => :get,
        :new => :get,
        :create => :put,
        :place => :put,
        :cancel_paypal => :get,
        :invite=>:get,
        :send_invitations => :put,
        :confirm => :put,
        :close=>:put,
        :closed=>:get
        } do |orders|
      orders.resources :order_items, :member=>{:make=>:put}
    end
    shops.resources :menus, :shallow=>true, :member=>{:reorder_menu_items=>:post},
      :collection=>{:import=>:get, :import_csv=>:post} do |menus|
      menus.resources :menu_items, :shallow=>true, :member=>{:reorder_flavours=>:post, :reorder_sizes=>:post} do |menu_items|
        menu_items.resources :sizes
        menu_items.resources :flavours
      end
    end 
  end
  
  map.resources :content, :only=>[], :collection=>{
    :bounty_conditions=>:get,
    :why_inaccurate=>:get,
    :privacy_policy=>:get,
    :site_terms=>:get,
    :faq => :get,
    :credits => :get
    }
    
  map.owners '/owners', :controller=>:content, :action=>:owners, :conditions=>{:subdomain=>false}

  map.shop_root '', :controller=>:shops, :action=>:show, :conditions=>{:subdomain=>/.+/}

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

