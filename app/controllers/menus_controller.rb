class MenusController < ApplicationController
  
  def new
    @shop = Shop.find(params[:shop_id])
    @menu = @shop.menus.build
  end                        
  
  def create 
    @shop = Shop.find(params[:shop_id])
    @menu = @shop.menus.build(params[:menu])
    if @menu.save
        redirect_to edit_shop_path(@shop)
    else                    
      redirect_to new_shop_menu_path(@shop)
    end
      
  end
end
