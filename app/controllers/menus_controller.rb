class MenusController < ApplicationController

  before_filter :find_instance, :except => [:index, :new, :create]
  before_filter :require_login, :except=>[:show]
  before_filter :require_manager_or_admin, :only=>[:edit, :destroy, :update, :create]

  
  def new             
    if params[:shop_id] # Shop menu
      @shop = Shop.find_by_id_or_permalink(params[:shop_id])
      @menu = @shop.menus.build
    else
      @menu = Menu.new # Generic Menu (ie doesn't belong to a shop)
    end
  end                        

  def index
    @menus = Menu.generic.all
  end

  def create                          
    template_id = params[:menu_template_id]
    menu_template = MenuTemplate.find(template_id) if template_id
    menu_data = menu_template ? menu_template.menu_params : params[:menu]
    if params[:shop_id]
      @shop = Shop.find_by_id_or_permalink(params[:shop_id])                      
      @menu = @shop.menus.build(menu_data) 
    else
      @menu = Menu.new(menu_data)
    end
    if @menu.save
      redirect_to edit_menu_path(@menu)
    else
      redirect_to @menu.generic? ? new_menu_path : new_shop_menu_path(@shop)
    end
  end
  
  def edit
    @menu = Menu.find(params[:id])
  end   
  
  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      redirect_to @menu.generic? ? menus_path : edit_shop_path(@menu.shop)
    else
      render :action=>'edit'
    end
  end  
  
  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy 
    redirect_to @menu.generic? ? menus_path : edit_shop_path(@menu.shop)
  end  
  
  def reorder_menu_items
    reorder_child_items :menu_item
  end          
       
private

  def find_instance
    @menu = Menu.find(params[:id])
  end
  
  def require_manager_or_admin
    unless current_user.is_admin? or @menu.andand.shop.andand.is_manager?(current_user)
      flash[:error] = "You're not authorized to do that."
      redirect_to root_path
    end
  end
  
end
