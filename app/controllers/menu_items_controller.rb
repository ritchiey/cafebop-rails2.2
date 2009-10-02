class MenuItemsController < ApplicationController
            
  before_filter :get_menu, :only=>[:new, :create]
  
  def new
    @menu_item = @menu.menu_items.build
  end    
  
  def create
    @menu_item = @menu.menu_items.build(params[:menu_item])
    if @menu_item.save
      redirect_to edit_menu_path(@menu)
    else
      render :action=>'new'
    end
  end          
  
  def edit
    @menu_item = MenuItem.find(params[:id])
  end          
  
private

  def get_menu
    @menu = Menu.find(params[:menu_id])
  end
  
end
