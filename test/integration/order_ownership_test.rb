require 'test_helper'   
require 'interactions'

class OrderOwnershipTest < ActionController::IntegrationTest
  setup :activate_authlogic 
  
  include Interactions

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

  def test_listing_orders
    assert !@anon.can_list_orders?
    assert !@harry.can_list_orders?
    assert @admin.can_list_orders?
  end

  def test_authenticated_cant_access_anonymous_order
    assert_not_nil(anons_order = @anon.creates_an_order)
    assert @anon.can_see?(anons_order)
    assert @anon.can_edit?(anons_order)
    assert @anon.can_update?(anons_order) 
    assert !@harry.can_see?(anons_order)
    assert !@harry.can_edit?(anons_order)
    assert !@harry.can_update?(anons_order)
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


end