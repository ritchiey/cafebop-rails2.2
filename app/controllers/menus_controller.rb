class MenusController < ApplicationController

  before_filter :find_instance, :except => [:index, :new, :create, :import, :import_csv]
  before_filter :require_login, :except=>[:show]
  before_filter :require_manager_or_admin, :except=>[:show]


  class ::MenuImport
    attr_accessor :prefix
    attr_accessor :data  
    def id() 1; end
    def new_record?() true; end
    def self.human_name() "Menu Import"; end
  end
                
  def import
    @menu_import = MenuImport.new
  end

  def import_csv
    data = params[:menu_import][:data]
    prefix = params[:menu_import][:prefix]
    data and Menu.import_csv(prefix, data)
    redirect_to menus_path
  end
  
  def new             
    if params[:shop_id] # Shop menu
      @shop = Shop.find_by_id_or_permalink(params[:shop_id])
      @menu = @shop.menus.build
    else
      @menu = Menu.new # Generic Menu (ie doesn't belong to a shop)
    end
  end                        

  def index
    @menus = Menu.generic.all
  end

  def create                          
    template_id = params[:menu_template_id]
    menu_template = MenuTemplate.find(template_id) if template_id
    menu_data = menu_template ? menu_template.menu_params : params[:menu]
    if params[:shop_id]
      @shop = Shop.find_by_id_or_permalink(params[:shop_id])                      
      @menu = @shop.menus.build(menu_data) 
    else
      @menu = Menu.new(menu_data)
    end
    if @menu.save
      redirect_to edit_menu_path(@menu)
    else
      redirect_to @menu.generic? ? new_menu_path : new_shop_menu_path(@shop)
    end
  end
  
  def edit
    @menu = Menu.find(params[:id])
  end   
  
  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      redirect_to @menu.generic? ? menus_path : edit_shop_path(@menu.shop)
    else
      render :action=>'edit'
    end
  end  
  
  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy 
    redirect_to @menu.generic? ? menus_path : edit_shop_path(@menu.shop)
  end  
  
       
private

  def reorder_children
    reorder_child_items :menu_item
  end

  def find_instance
    @menu ||= Menu.find(params[:id])
  end
  
  
  def require_manager_or_admin       
    @shop = Shop.find_by_id_or_permalink(params[:shop_id]) if params[:shop_id]
    unless current_user and
          (current_user.is_admin? or
          current_user.manages?(@shop) or
          current_user.manages?(@menu.andand.shop))
      flash[:error] = "You're not authorized to do that."
      redirect_to root_path
    end
  end
  
end
