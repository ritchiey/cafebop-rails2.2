class MenuItemsController < ApplicationController
            
  before_filter :get_menu, :only=>[:new, :create]
  before_filter :find_instance, :except=>[:new, :create]
  before_filter :only_manager_or_admin
  
  
  
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
                         
  def destroy
    @menu_item = MenuItem.find(params[:id])
    @menu_item.destroy
    redirect_to edit_menu_path(@menu_item.menu)
  end


  def update
    @menu_item = MenuItem.find(params[:id])
    if @menu_item.update_attributes(params[:menu_item])
      redirect_to edit_menu_path(@menu_item.menu)
    else
      render :action=>'edit'
    end
  end

  def reorder_sizes
    reorder_child_items :size
  end

  def reorder_flavours
    reorder_child_items :flavour
  end

private

  def find_instance
    @menu_item = MenuItem.find(params[:id])
  end

  def get_menu
    @menu = Menu.find(params[:menu_id])
  end                
  
  def only_manager_or_admin
    unless current_user and (current_user.is_admin? or
          @menu_item.andand.managed_by?(current_user) or
          @menu.andand.managed_by?(current_user))
      flash[:error] = "You're not authorized to do that."
      redirect_to root_path
    end
  end
end
