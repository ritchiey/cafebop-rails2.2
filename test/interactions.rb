module Interactions

  def as(email, password)
    open_session do |sess|
      sess.extend(CustomAssertions)
      sess.get root_path # get past the whole cookies_required thing
      sess.post_via_redirect user_sessions_path, :user_session=>{:email=>email, :password=>password}
      sess.assert_template :partial=>'_authenticated_nav'
      assert sess.assigns(:current_user)
    end
  end

  def anonymously
    open_session do |sess|
      sess.extend(CustomAssertions)
      sess.get_via_redirect root_path # get past the whole cookies_required thing
      sess.assert_template :partial=>'_unauthenticated_nav'
      assert !sess.assigns(:current_user)
    end
  end

private

  module CustomAssertions

    def invites email, options
      options[:to].tap do |order|
        get invite_order_url(order)
        post order_url(order),
          {"commit"=>"Continue",
            :friendship=>{"friend_email"=>""},
            :order=>{:invited_user_attributes=>[email],
              :id=>order.id,
              :start_close_timer=>"true", 
              :page=>"summary",
              :minutes_til_close=>"10"
            }
          }           
      end
    end

    def accepts_invitation_sent_to user
      order = Order.user_id_eq(user.id).last
      assert_not_nil order, "Couldn't find an invitation sent to #{user.email}"
      
    end
  
    def can_list_orders?(shop)
      get shop_past_orders_path(shop)
      @response.success?
    end
                    
    def can_see? order
      get order_url(order)
      @response.success?
    end
  
    def can_edit? order
      get edit_order_url(order)
      @response.success?
    end     
  
    def creates_an_order options={}
      menu_item = options[:for] || MenuItem.make
      quantity = options[:quantity] || 1   
      post shop_orders_path(menu_item.shop),
        'order[order_items_attributes][][quantity]' => '1',
        'order[order_items_attributes][][menu_item_id]' => menu_item.id.to_s,
        'order[order_items_attributes][][notes]' => 'from functional test'
      Order.last
    end    
  
    def can_update? order, options={}
      menu_item = options[:for] || MenuItem.make
      quantity = options[:quantity] || 1   
      put_via_redirect order_path(order),
        'order[order_items_attributes][][quantity]' => '1',
        'order[order_items_attributes][][menu_item_id]' => menu_item.id.to_s,
        'order[order_items_attributes][][notes]' => 'from functional test' 
      order.reload
      order.order_items.*.menu_item.include?(menu_item)
    end    
  
  
  
    def can_destroy?(order)
      count = Order.count
      delete_via_redirect order_path(order)
      Order.count == count - 1
    end
  end

end