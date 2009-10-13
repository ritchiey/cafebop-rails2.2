class FlavoursController < ApplicationController
  
  def new
    @menu_item = MenuItem.find(params[:menu_item_id])
    @flavour = @menu_item.flavours.build
  end
  
  def create
    @menu_item = MenuItem.find(params[:menu_item_id])
    @flavour = @menu_item.flavours.build(params[:flavour])
    if @flavour.save
      redirect_to edit_menu_item_path(@menu_item)
    else
      render :action=>'new'
    end
  end                      
  
  
end
