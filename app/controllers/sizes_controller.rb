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
  
  
end
