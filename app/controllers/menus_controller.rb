class MenusController < ApplicationController
  
  def new
    @shop = Shop.find(params[:shop_id])
    @menu = @shop.menus.build
  end                        
  
  def create 
    @shop = Shop.find(params[:shop_id])
    @template = MenuTemplate.find(params[:menu_template_id])
    menu_data = @template ? @template.menu_params : params[:menu]
    @menu = @shop.menus.build(menu_data) 
    if @menu.save
        redirect_to edit_shop_path(@shop)
    else                    
      redirect_to new_shop_menu_path(@shop)
    end
  end
  
  def edit
    @menu = Menu.find(params[:id])
  end   
  
  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      redirect_to edit_shop_path(@menu.shop)
    else
      render :action=>'edit'
    end
  end
end
