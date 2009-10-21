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
  
  def edit
    @flavour = Flavour.find(params[:id])
  end
                     
  def update
    @flavour = Flavour.find(params[:id])
    if @flavour.update_attributes(params[:flavour])
      redirect_to edit_menu_item_path(@flavour.menu_item)
    else
      render :action=>'edit'
    end
  end  
end
