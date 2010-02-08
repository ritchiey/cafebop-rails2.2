class FlavoursController < ApplicationController

  before_filter :get_menu_item, :only=>[:new, :create]
  before_filter :find_instance, :except=>[:new, :create]
  before_filter :only_manager_or_admin

  
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
  
  private
  
    def find_instance
      @flavour = Flavour.find(params[:id])
    end

    def get_menu_item
      @menu_item = MenuItem.find(params[:menu_item_id])
    end                

    def only_manager_or_admin
      unless current_user and (current_user.is_admin? or
            @flavour.andand.managed_by?(current_user) or
            @menu_item.andand.managed_by?(current_user))
        flash[:error] = "You're not authorized to do that."
        redirect_to root_path
      end
    end
  
end
