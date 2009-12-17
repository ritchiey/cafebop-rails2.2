require 'test_helper'

class OrderOwnershipTest < ActionController::IntegrationTest
  setup :activate_authlogic

  def setup
    password = "quiddich"
    @harry_user = User.make(:active=>true, :email=>"harry@hogwarts.edu", :password=>password, :password_confirmation=>password)
    admin_user = User.make(:active=>true, :roles=>['cafebop_admin'], :email=>"snape@hogwarts.edu", :password=>password, :password_confirmation=>password)
    assert admin_user.is_admin?
    @anon = anonymously
    @harry = as(@harry_user.email, password)
    @harry_again = as(@harry_user.email, password)
    @admin = as(admin_user.email, password)
  end

  def test_authenticated_cant_access_anonymous_order
    assert_not_nil(anons_order = @anon.creates_an_order)
    assert @anon.can_see?(anons_order)
    assert @anon.can_edit?(anons_order)
    # assert anon.can_add_an_item_to?(anons_order)
    assert !@harry.can_see?(anons_order)
    assert !@harry.can_edit?(anons_order)
    # assert !harry.can_add_an_item_to?(anons_order)
    # assert anon.can_invite(anons_order)
    assert !@anon.can_destroy?(anons_order)
    assert !@harry.can_destroy?(anons_order) 
    assert @admin.can_destroy?(anons_order)
  end

  def test_authenticated_user_can_access_own_order_in_new_session
    assert_not_nil(harrys_order = @harry.creates_an_order)
    assert @harry.can_see?(harrys_order)
    assert @harry.can_edit?(harrys_order)
    assert !@anon.can_see?(harrys_order)
    assert !@anon.can_edit?(harrys_order)
    assert @harry_again.can_see?(harrys_order)
    assert @harry_again.can_edit?(harrys_order)
  end

private

  module CustomAssertions
                      
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
    
    
    def can_destroy?(order)
      count = Order.count
      delete_via_redirect order_path(order)
      Order.count == count - 1
    end
  end

  def as(email, password)
    open_session do |sess|
      sess.extend(CustomAssertions)
      sess.get root_path # get past the whole cookies_required thing
      sess.post user_sessions_path, :user_session=>{:email=>email, :password=>password}
      #assert assigns(:current_user)
    end
  end
  
  def anonymously
    open_session do |sess|
      sess.extend(CustomAssertions)
      sess.get root_path # get past the whole cookies_required thing
      #assert !assigns(:current_user)
    end
  end
end