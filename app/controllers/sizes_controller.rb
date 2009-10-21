class SizesController < ApplicationController   
  
  def new
    @menu_item = MenuItem.find(params[:menu_item_id])
    @size = @menu_item.sizes.build
  end      
  
  def create
    @menu_item = MenuItem.find(params[:menu_item_id])
    @menu_item.sizes.build(params[:size])
    if @menu_item.save
      redirect_to edit_menu_item_path(@menu_item)
    else
      render :action=>:new
    end
  end                            
  
  def edit
    @size = Size.find(params[:id])
  end
  
  def update
    @size = Size.find(params[:id])
    if @size.update_attributes(params[:size])
      redirect_to edit_menu_item_path(@size.menu_item)
    else
      render :action=>'edit'
    end
  end  
  
end
