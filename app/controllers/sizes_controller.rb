class SizesController < ApplicationController   
  
  before_filter :get_menu_item, :only=>[:new, :create]
  before_filter :find_instance, :except=>[:new, :create]
  before_filter :only_manager_or_admin

  
  def new
    @menu_item = MenuItem.find(params[:menu_item_id])
    @size = @menu_item.sizes.build
  end      
  
  def create
    @size = @menu_item.sizes.build(params[:size])
    if @size.save
      redirect_to edit_menu_item_path(@menu_item)
    else
      render :action=>:new
    end
  end                            
  
  def edit
  end
  
  def update
    if @size.update_attributes(params[:size])
      redirect_to edit_menu_item_path(@size.menu_item)
    else
      render :action=>'edit'
    end
  end  
  
  private
  
    def find_instance
      @size = Size.find(params[:id])
    end

    def get_menu_item
      @menu_item = MenuItem.find(params[:menu_item_id])
    end                

    def only_manager_or_admin
      unless current_user and (current_user.is_admin? or
            @size.andand.managed_by?(current_user) or
            @menu_item.andand.managed_by?(current_user))
        flash[:error] = "You're not authorized to do that."
        redirect_to root_path
      end
    end
  

end
