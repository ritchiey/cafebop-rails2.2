class MenusController < ApplicationController
  
  def new
    @shop = Shop.find(params[:shop_id])
    @menu = @shop.menus.build
  end                        

  def index
    @menus = Menu.generic.all
  end

  def create 
    @shop = Shop.find(params[:shop_id])                      
    template_id = params[:menu_template_id]
    menu_template = MenuTemplate.find(template_id) if template_id
    menu_data = menu_template ? menu_template.menu_params : params[:menu]
    @menu = @shop.menus.build(menu_data) 
    if @menu.save
        redirect_to edit_menu_path(@menu)
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
  
  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy 
    redirect_to edit_shop_path(@menu.shop)
  end  
  
  def reorder_menu_items
    reorder_child_items :menu_item
  end          
       
private

  def find_instance
    @menu = Menu.find(params[:id])
  end
  
  
end
