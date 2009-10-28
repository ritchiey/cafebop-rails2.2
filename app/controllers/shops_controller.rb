class ShopsController < ApplicationController    

  before_filter :find_instance, :except=>[:new, :create, :index, :search]          
  before_filter :can_edit, :only=>[:edit, :update]
  
  def new
    @shop = Shop.new
    @shop.menus.build
  end               
  
  def show
    @shop = Shop.find(params[:id])
    redirect_to new_shop_order_path(@shop)
  end
  
  def create
    @shop = Shop.new(params[:shop])
    if @shop.save
      redirect_to root_path
    else                   
      render :action=>'new'
    end
  end
            
  def index
    @shops = Shop.all
  end
              
  def search
    @search = Search.new(params[:search])
    @shops = @search.shops   
    respond_to do |wants|
      wants.html
      wants.json {render_json @shops.to_json(:only=>[:id, :name])}
    end
  end        
  
  def edit
    @shop = Shop.find(params[:id])
  end  
  
  def update
    if @shop.update_attributes(params[:shop])
      redirect_to shops_path
    else
      render :action=>:edit
    end
  end


  def reorder_menus
    reorder_child_items(:menu)
  end                 
  
  def reorder_item_queues
    reorder_child_items(:item_queue)
  end
                                    
    
private

    def find_instance
      @shop = Shop.find(params[:id])
    end

    def can_edit
      unless @shop.can_edit?(current_user)
        flash[:error] = "You aren't authorized to do that."
        redirect_to root_path
      end
    end  
    
end
