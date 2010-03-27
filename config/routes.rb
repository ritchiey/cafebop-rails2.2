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
  map.resources :claims, :member=>{:review=>:put, :confirm=>:put, :reject=>:put}
  
  map.resources :orders, :collection=>{:accept=>:get, :decline=>:get}
  map.resources :order_items  

  map.resources :menus, :only=>[:new, :create, :index], # for generic menus
    :collection=>{:import=>:get, :import_csv=>:post}

  map.resources :queued_orders, :only=>[:show], :member=>{:cancel=>:put, :no_show=>:put, :deliver => :put, :make_all_items=>:put}
  map.resources :queued_order_items, :only=>[:show],
    :member=>{:make=>:put},
    :collection=>{:make_all=>:put}

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
      :start_queuing=>:put,
      :stop_queuing=>:put,
      :start_paypal=>:put,
      :stop_paypal=>:put
      } do |shops|
    shops.resources :votes, :only=>[:create]
    shops.resources :operating_times
    shops.resources :item_queues, :member=>{:current_items=>:get, :stop=>:put, :start=>:put}
    shops.resources :customer_queues, :member=>{:current_orders=>:get, :stop=>:put, :start=>:put}
    shops.resources :claims, :only=>[:new, :create]
    shops.resources :past_orders
    shops.resources :orders, :shallow => true, :member => {
        :status_of_pending => :get,
        :status_of_queued => :get,
        :summary => :get,
        :new => :get,
        :create => :put,
        :place => :put,
        # :pay_in_shop => :put,
        # :pay_paypal => :put,
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

  
  map.root :controller => "front", :action=>'index', :host=>:host

  

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'     
end

