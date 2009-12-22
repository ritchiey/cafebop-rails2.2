class ShopsController < ApplicationController      
  
  before_filter :require_login, :except=>[:search]
  before_filter :find_instance, :except=>[:new, :create, :index, :search]          
  before_filter :require_manager_or_admin, :only=>[:edit, :update]
  before_filter :require_admin, :only => [:destroy]

  def new
    @shop = Shop.new
    @shop.menus.build
  end               
  
  def show
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
    @shop = Shop.find_by_permalink(params[:id])
  end  
  
  def update
    if @shop.update_attributes(params[:shop])
      redirect_to new_shop_order_path(@shop)
    else
      render :action=>:edit
    end
  end

  def start_queuing
    @shop.start_accepting_queued_orders!
    render :partial=>'queuing_status'
  end

  def stop_queuing
    @shop.stop_accepting_queued_orders!
    render :partial=>'queuing_status'
  end

  def start_paypal
    @shop.enable_paypal_payments!
    render :partial=>'paypal_status'
  end

  def stop_paypal
    @shop.disable_paypal_payments!
    render :partial=>'paypal_status'
  end

  def reorder_menus
    reorder_child_items(:menu)
  end                 
  
  def reorder_item_queues
    reorder_child_items(:item_queue)
  end
                                    
  def reorder_operating_times
    reorder_child_items(:operating_time)
  end
  
  def destroy
    @shop.destroy
    flash[:notice] = "Successfully destroyed shop."
    redirect_to root_path
  end
    
private

    def find_instance
      @shop = Shop.find_by_permalink(params[:id])
    end

    def can_edit
      unless @shop.can_edit?(current_user)
        flash[:error] = "You aren't authorized to do that."
        redirect_to root_path
      end
    end  
    
    
    def require_manager_or_admin
      unless current_user.is_admin? or @shop.is_manager?(current_user)
        flash[:error] = "You're not authorised to do that."
        redirect_to new_shop_order_path(@shop)
      end
    end
    
    def require_admin
      unless current_user.is_admin?
        flash[:error] = "You're not authorised to do that."
        redirect_to new_shop_order_path(@shop)
      end
    end
end
