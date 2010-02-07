require 'test_helper'

class MenuItemsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  context "Given a shop with a menu with one menu_item" do
    setup do
      @shop = Shop.make
      @menu = @shop.menus.make
      @menu_item = @menu.menu_items.make
      @valid = @menu.menu_items.make_unsaved.attributes
    end
    
    context "as manager of shop" do
      setup do
        login_as manager_of(@shop)
      end
    
      context "when editing" do
        setup do
          get :edit, :id=>@menu_item.id
        end
        should_assign_to(:menu_item) {@menu_item}
        should_respond_with :success
        should_render_with_layout
        should_render_template :edit
        should_not_set_the_flash
      end
    
      context "when adding" do
        setup do
          get :new, :menu_id=>@menu.id
        end
        should_assign_to(:menu_item, :class=>MenuItem)
        should_respond_with :success
        should_render_with_layout
        should_render_template :new
        should_not_set_the_flash
      end      
    
      context "when creating a menu item" do
        context "with valid data" do
          setup do
            post :create, :menu_id=>@menu.id, :menu_item=>@valid.merge(:name=>'Grub')
          end
          should_assign_to :menu_item, :class=>MenuItem
          should_redirect_to('edit page for the menu') {edit_menu_path(@menu)}
          should_not_set_the_flash
        end
      end
    
      context "when updating" do
        context "with valid data" do
          setup do
            put :update, :id=>@menu_item.id, :menu_item=>{:name=>'Grub'}
          end
          should_assign_to(:menu_item) {@menu_item}
          should_redirect_to("edit menu") {edit_menu_url(@menu)}
          should_not_set_the_flash
        end
      end
      
    end
           
    
    context "as admin" do
      setup do
        login_as_admin
      end
    
      context "when editing" do
        setup do
          get :edit, :id=>@menu_item.id
        end
        should_assign_to(:menu_item) {@menu_item}
        should_respond_with :success
        should_render_with_layout
        should_render_template :edit
        should_not_set_the_flash
      end
    
      context "when adding" do
        setup do
          get :new, :menu_id=>@menu.id
        end
        should_assign_to(:menu_item, :class=>MenuItem)
        should_respond_with :success
        should_render_with_layout
        should_render_template :new
        should_not_set_the_flash
      end      
    
      context "when creating a menu item" do
        context "with valid data" do
          setup do
            post :create, :menu_id=>@menu.id, :menu_item=>@valid.merge(:name=>'Grub')
          end
          should_assign_to :menu_item, :class=>MenuItem
          should_redirect_to('edit page for the menu') {edit_menu_path(@menu)}
          should_not_set_the_flash
        end
      end
    
      context "when updating" do
        context "with valid data" do
          setup do
            put :update, :id=>@menu_item.id, :menu_item=>{:name=>'Grub'}
          end
          should_assign_to(:menu_item) {@menu_item}
          should_redirect_to("edit menu") {edit_menu_url(@menu)}
          should_not_set_the_flash
        end
      end
      
    end    
  end
end





