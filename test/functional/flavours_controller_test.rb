require 'test_helper'

class FlavoursControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def self.should_not_let_me
    should_redirect_to("home page") {root_path}
    should_set_the_flash_to "You're not authorized to do that."
  end     
  
  def self.should_let_me_edit
    should_assign_to(:flavour) {@flavour}
    should_respond_with :success
    should_render_with_layout
    should_render_template :edit
    should_not_set_the_flash
  end

  def self.should_display_new_page
    should_assign_to(:flavour, :class=>Flavour)
    should_respond_with :success
    should_render_with_layout
    should_render_template :new
    should_not_set_the_flash
  end


  def self.should_redirect_to_edit_page
   should_assign_to :flavour, :class=>Flavour
   should_redirect_to('edit page for the menu_item') {edit_menu_item_path(@menu_item)}
   should_not_set_the_flash
  end

  def self.when_creating
   context "when creating a flavour" do
     context "with valid data" do
       setup do
         post :create, :menu_item_id=>@menu_item.id, :flavour=>@valid.merge(:name=>'Porcupine')
       end
       context "" do
         yield
       end
     end
   end
  end


  def self.when_adding
    context "when adding" do
      setup do
        get :new, :menu_item_id=>@menu_item.id
      end
      context "" do
        yield
      end
    end      
  end

  def self.when_editing
    context "when editing" do
      setup do
        get :edit, :id=>@flavour.id
      end
      context "" do
        yield
      end
    end
  end
  
  def self.when_updating_with_valid_data
    context "when updating with valid data" do
      setup do
        put :update, :id=>@flavour.id, :flavour=>{:name=>'Willow'}
      end
      context "" do
        yield
      end
    end
  end

  def self.as user
    context "As #{user.name}" do
      setup do
        login_as user
      end
      context "" do
        yield
      end
    end
  end
  
  def self.admin
    User.make(:active).tap { |user| user.add_role('cafebop_admin') }   
  end

    
  context "Given a shop with a menu with one menu_item with a flavour" do
    setup do
      @shop = Shop.make
      @menu = @shop.menus.make
      @menu_item = @menu.menu_items.make
      @flavour = @menu_item.flavours.make
      @valid = @menu_item.flavours.make_unsaved.attributes
    end

    as admin do
      when_editing {should_let_me_edit}
      when_adding {should_display_new_page}
      when_creating {should_redirect_to_edit_page}
      when_updating_with_valid_data {should_redirect_to_edit_page}
    end    

    context "as manager" do
      setup do
        login_as manager_of(@shop)
      end

      when_editing {should_let_me_edit}
      when_adding {should_display_new_page}
      when_creating {should_redirect_to_edit_page}
      when_updating_with_valid_data {should_redirect_to_edit_page}
    end
    
    context "as staff" do
      setup do
        login_as staff_of(@shop)
      end

      when_editing {should_not_let_me}
      when_adding {should_not_let_me}
      when_creating {should_not_let_me}
      when_updating_with_valid_data {should_not_let_me}
    end

    context "as an unauthenticated user" do
      when_editing {should_not_let_me}
      when_adding {should_not_let_me}
      when_creating {should_not_let_me}
      when_updating_with_valid_data {should_not_let_me}
    end


  end
end





