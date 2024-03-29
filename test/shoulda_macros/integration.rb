class ActionController::IntegrationTest        

  def login options={}                     
    password = options[:password] || "bluebell"
    (options[:as] || User.make(:active=>true, :password=>password, :password_confirmation=>password)).tap do |user|
      visit root_url
      click_link 'login'
      fill_in "user_session_email", :with=>user.email
      fill_in "user_session_password", :with=>password
      click_button "user_session_submit"
      assert_logged_in_as user
    end
  end

  def assert_logged_in_as user
    assert_contain "Logout"
    assert_contain "Logged in as #{user}"
  end     

  def assert_logged_out
    assert_not_contain "Logged in as"
    assert_contain "Login"  
  end                    
  
  def logout
    click_link "Logout"    
  end

  def place_webrat_order options={}
    menu_item = options[:for] || MenuItem.make
    quantity = options[:quantity] || 1
    name_param = (options[:name]) ? {:name=>options[:name]} : {}
    # TODO:can't currently test this easily because it requires javascript
    # so we'll fake it by creating the order
    #visit shop_path(menu_item.menu.shop)
    visit shop_orders_path(menu_item.shop), :post,:order=>{
      :order_items_attributes=>[{
          :quantity=>quantity.to_s,
          :menu_item_id=>menu_item.id.to_s,
          :notes=>'from integration test'
        }
      ]
    }.merge(name_param)
    Order.last # TODO: this could be more robust   
  end

  def add_to_last_webrat_order options={}
    menu_item = options[:for] || MenuItem.make
    quantity = options[:quantity] || 1
    Order.last.tap do |order|
      visit order_url(order), :put,
        'order[order_items_attributes][][quantity]' => '1',
        'order[order_items_attributes][][menu_item_id]' => menu_item.id.to_s,
        'order[order_items_attributes][][notes]' => 'added to existing order'
    end
  end
  
  def add_friend email
    visit root_path
    fill_in "friendship_friend_email", :with=>email
    click_button "Add"   
  end
  
end