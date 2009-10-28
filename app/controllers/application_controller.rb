# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  


  filter_parameter_logging :password, :password_confirmation
  
  helper_method :current_user_session, :current_user

  protected
                                                        
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def require_login
    unless current_user
      flash[:notice] = 'Please login'
      redirect_to new_user_session_path
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


private

  def unauthorized
    flash[:notice] = "You're not authorized to do that."
    redirect_to root_path
  end    
                     
end
