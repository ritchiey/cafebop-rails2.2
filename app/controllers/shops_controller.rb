class ShopsController < ApplicationController      
  
  before_filter :cookies_required, :except => [:cookies_test, :show]
  before_filter :require_login, :except=>[:search, :show, :index, :create, :new, :update]
  before_filter :fetch_shop, :except=>[:new, :create, :index, :search]
  before_filter :require_manager_or_admin, :only=>[:edit]
  before_filter :require_admin, :only => [:destroy, :import_form, :import]
  before_filter :current_user_collections, :only=>[:search]

  def new
    @shop = Shop.new
    @shop.menus.build
  end               
  
  def show
    respond_to do |format|
      format.html {redirect_to shop_new_order_path(@shop)}
      format.mobile
      format.json { render :json=>@shop.to_json(
        :only=>[:id, :name],
        :include=>{
          :customer_queues=>{:only=>[:name, :id, :active]},
          :item_queues=>{:only=>[:name, :id, :active]}
        })}
    end
  end    
  
  def create                   
    shop_params = params[:shop]
    unless current_user and current_user.is_admin?
      shop_params.delete(:owner_email)
    end
    @shop = Shop.new(shop_params)
    if @shop.save
      redirect_to new_shop_order_path(@shop)
    else                   
      render :action=>'new'
    end
  end
            
  def index
    @page = params[:page]
    @shops = Shop.ascend_by_name.paginate(:per_page=>20, :page=>@page)
  end
              
  def search
    if params[:search] 
      @search = Search.new(params[:search])
        @page = params[:page]
      @shops = @search.shops.paginate(:per_page=>8, :page=>@page)
      respond_to do |wants|
        wants.html
        wants.json {render_json @shops.to_json(:only=>[:id, :name])}
      end
    else
      redirect_to shops_path
    end
  end                  
  
  def cuisineless
    @shops = Shop.with_no_cuisine
  end
  
  def guess_cuisines_for
    Shop.with_no_cuisine.each do |shop|
      shop.guess_cuisines
    end
    redirect_to cuisineless_shops_path
  end
  
  def refund_policy_for
  end
  
  def edit
  end  
  
  def update
    changes = params[:shop]  
    require_manager_or_admin and return
    if @shop.update_attributes(changes)
      redirect_to new_shop_order_path(@shop)
    else
      render :action=>:edit
    end
  end

  # def start_queuing
  #   @shop.start_accepting_queued_orders!
  #   render :partial=>'queuing_status'
  # end
  # 
  # def stop_queuing
  #   @shop.stop_accepting_queued_orders!
  #   render :partial=>'queuing_status'
  # end
  # 
  # def start_paypal
  #   @shop.enable_paypal_payments!
  #   render :partial=>'queuing_status'
  # end
  # 
  # def stop_paypal
  #   @shop.disable_paypal_payments!
  #   render :partial=>'queuing_status'
  # end

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
  
  
  def import_form
  end


  def import  
    data = params[:data]
    StringIO.open(data, 'r') do |io|
      io.each_line do |line|
        (name, phone, address) = line.split(/\|\s*/)
        Shop.find_or_create_by_name(:name=>name, :phone=>phone, :street_address=>address)
      end
    end
    redirect_to shops_path
  end
  
protected

  def search_term_for_shop
    params[:id] || current_subdomain
  end
    
private

    # def find_instance  
    #   @shop = Shop.find_by_id_or_permalink(params[:id] || current_subdomain)
    # end

    def can_edit
      unless @shop.can_edit?(current_user)
        flash[:error] = "You aren't authorized to do that."
        redirect_to root_path
      end
    end  
    
    
    def require_manager_or_admin
      if current_user
        unless current_user.is_admin? or @shop.is_manager?(current_user)
          flash[:error] = "You're not authorized to do that."
          redirect_to new_shop_order_path(@shop)
        end
      else
        redirect_to login_path
      end
    end
    
    def require_admin
      if current_user 
        unless current_user.is_admin?
          flash[:error] = "You're not authorized to do that."
          redirect_to new_shop_order_path(@shop)
        end
      else
        redirect_to login_path
      end
    end
    
end
