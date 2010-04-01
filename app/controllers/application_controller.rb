# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :log_request_details
  before_filter :cookies_required, :except => [:cookies_test]
  before_filter :fetch_shop, :except => [:cookies_test]
  # before_filter :fetch_order, :except => [:cookies_test]
  before_filter :default_objects
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :adjust_format_for_mobile
  filter_parameter_logging :password, :password_confirmation
  
  helper_method :current_user_session, :current_user, :admin?,
    :shop_edit_path, :shop_new_order_path
  
  def persist_to store, target, options={}
    Persistence.persist_to store, target, options
  end

  def restore_from store, target, options={}
    Persistence.restore_from store, target, options
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  alias_method :"authenticated?", :current_user

  protected
  
  def gateway
    @gateway ||= ActiveMerchant::Billing::PaypalAdaptivePaymentGateway.new(
     :login => ENV['PAYPAL_LOGIN'] || 'us_1261469612_biz_api1.cafebop.com',
     :password => ENV['PAYPAL_PASSWORD'] || '1261469614',
     :signature => ENV['PAYPAL_SIGNATURE'] || 'A4ST5PBqjKmYFbqmR24zb37caokmALi8VgzXjcetjlgH7hvloAlXecuB',
     :appid => ENV['PAYPAL_APP_ID'] || 'APP-80W284485P519543T'
    )
  end

  def browser_session
    @browser_session ||= BrowserSession.new(session)
  end        
  helper_method :browser_session
  
  def login_as user
    UserSession.create(user)
  end
                                                        
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  
  def admin?
    current_user and current_user.is_admin?
  end
  
  def require_login message = 'Please login'
    unless current_user
      flash[:notice] = message
      redirect_to login_path
    end
  end      
  
  def require_can_review_claims
    unauthorized unless current_user && current_user.can_review_claims?
  end      
  
  def require_admin_rights
    unauthorized unless current_user && current_user.is_admin?
  end

  def require_valid_captcha
    unless verify_recaptcha
     flash[:error] = "The Captcha words you entered weren't right."
     redirect_to :back
    end
  end        
  
  def redirect_back_or_default(path=root_path)
    redirect_to :back
  rescue
    redirect_to path
  end
  
  def reorder_child_items(child)
    child = child.to_s
    items = find_instance.send(child.pluralize)
    ordered_ids = params[child]
    find_instance.transaction do
      for item in items
        item.position = ordered_ids.index(item.id.to_s) + 1
        item.save
      end
    end
    render :nothing=>true
  end

  def cookies_test
    if request.cookies[SESSION_KEY].blank?
      logger.warn("** Cookies are disabled for #{request.remote_ip} at #{Time.now}" )
      flash[:error] = "Cookies are required for browsing this website"
      render :template => 'front/cookies_required'
    else
      redirect_to(session[:return_to] || {:controller => :front })
      session[:return_to] = nil
    end
  end


  def shop_edit_path(shop)
    shop or return nil
    if shop.permalink
      edit_url(:subdomain=>shop.permalink)
    else
      edit_shop_path(shop)
    end
  end
  
  def shop_new_order_path(shop)    
    if shop.permalink
      new_order_url(:subdomain=>shop.permalink)
    else
      new_shop_order_path(shop)
    end
  end



protected
  def cookies_required
    return unless request.cookies[SESSION_KEY].blank?
    session[:return_to] = request.request_uri
    redirect_to :controller => :front, :action => "cookies_test"
  end

  # If user_session parameters were passed and we're not currently
  # authenticated, then attempt authenticate
  def login_transparently
    if !current_user && params[:user_session]
      @user_session = UserSession.new(params[:user_session])
      unless @user_session.save
        flash[:error] = "Invalid email or password"
      end
    end
  end

  def no_cache
    response.headers["Cache-Control"] = "max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end


  def search_term_for_shop
    current_subdomain || params[:shop_id]
  end

  def fetch_shop
    @shop = find_shop(search_term_for_shop)
  end

  
  attr_accessor :include_with_shop
  def include_with_shop
    @include_with_shop ||= []
  end
  
  def include_menus_with_shop
    self.include_with_shop += [{:menus=>{:menu_items=>[:sizes,:flavours]}}]
  end

  def include_operating_times_with_shop
    self.include_with_shop += [:operating_times]
  end

  def find_shop term 
    term or return nil
    options = {:include=>include_with_shop}
    Shop.find_by_id_or_permalink(term, options)
  end


  def fetch_order
    @order = find_order(params[:id])
  end
  
  attr_accessor :include_with_order
  def include_with_order
    @include_with_order ||= []
  end    
  
  def include_items_with_order
    self.include_with_order = [:order_items]
  end      
  
  def find_order param       
    options = {:include=>include_with_order}
    if @shop
      @shop.orders.find(param, options)
    else
      order = Order.find(param, options)
      order and @shop = order.shop
      order
    end
  end
  
  


protected

  def current_user_collections
    if current_user
      @current_orders = current_user.orders.current.recent.newest_first.all
      @work_contracts = current_user.work_contracts.all(:include=>[:shop])
      @friendships = current_user.friendships.all(:include=>[:friend])
    end
  end

  def unauthorized
    flash[:notice] = "You're not authorized to do that."
    redirect_to root_path
  end    

  def adjust_format_for_mobile 
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_site? and request.format != 'application/json'
  end

  def mobile_site?           
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      mobile_device?
    end
  end
  helper_method :mobile_site?
  
  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  helper_method :mobile_device?
  
  def add_notice notice
    flash[:notices] ||= []
    flash[:notices] << notice
  end
  
  def been_asked_to_vote_for(shop)
    session[:asked_to_vote_for] ||= []
    session[:asked_to_vote_for].include?(shop.id)
  end
  
  def ask_to_vote_for(shop)
    session[:asked_to_vote_for] ||= []
    session[:asked_to_vote_for] << shop.id
  end
  

  # Find the shop by the shop_id parameter if specified in the request and
  # if the @shop instance variable hasn't already been set.
  # def find_order_and_or_shop
  #   order_id = params[:order_id]
  #   order_id and order_id.length > 0 and @order = Order.find(order_id, :include=>[{:shop=>[:operating_times]}])
  #   @order and @shop = @order.shop
  #   shop_id = params[:shop_id] and @shop ||= Shop.find_by_id_or_permalink(shop_id, :include=>[:operating_times])
  # end
  
  # We set these objects up here for the ajax login and signup forms that
  # appear on every page                   
  def default_objects
    @user = User.new
    @user_session = UserSession.new
    @user_session.errors.clear
    @user_session.remember_me = true
  end                   
                                 
  def log_request_details
    logger.info("Request Env: '#{request.env['HTTP_HOST']}'")
    logger.info("Current domain: '#{current_domain}'")
    logger.info("Current subdomain: '#{current_subdomain}'")
  end
  
end
