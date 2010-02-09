# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :'iphone_user_agent?'
  before_filter :cookies_required, :except => [:cookies_test]
  before_filter :find_order_and_or_shop, :except => [:cookies_test]
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :adjust_format_for_iphone
  filter_parameter_logging :password, :password_confirmation
  
  helper_method :current_user_session, :current_user, :"admin?"
  
  def persist_to store, target, options={}
    Persistence.persist_to store, target, options
  end

  def restore_from store, target, options={}
    Persistence.restore_from store, target, options
  end
  

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

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  alias_method :"authenticated?", :current_user
  
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

private

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

  # Set iPhone format if request to iphone.trawlr.com
  def adjust_format_for_iphone
    request.format = :iphone if iphone_user_agent?
  end

  def iphone_user_agent?           
    # return true
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/] or
    request.subdomains.first == "iphone" or params[:format] == "iphone"
  end
  
  
  # Find the shop by the shop_id parameter if specified in the request and
  # if the @shop instance variable hasn't already been set.
  def find_order_and_or_shop
    order_id = params[:order_id]
    order_id and @order = Order.find(order_id, :include=>[{:shop=>[:operating_times]}])
    @order and @shop = @order.shop
    shop_id = params[:shop_id] and @shop ||= Shop.find_by_id_or_permalink(shop_id, :include=>[:operating_times])
  end
                     
end
