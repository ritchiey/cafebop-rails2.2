class BrowserSession
  
  def initialize(session)
    @session = session
    @session[:order] ||= {}
  end                 

  def add_invite_details(params)
    %w/email minutes_til_closes invitees/.each do |attrib|
      session["invite_#{attrib}"] = params[attrib]
    end
  end
  
  def method_missing m
    session[m]
  end  
  
  def record_order_details params
    if op = params[:order]
      [:invited_user_attributes, :minutes_til_close].each { |attr| order_details[attr] = op[attr] }
    end                                        
    new_friend = params[:friendship]                                          
    new_friend and new_friend_email = new_friend[:friend_email]
    if new_friend_email and !new_friend_email.empty?
      order_details[:invited_user_attributes] ||= []
      order_details[:invited_user_attributes] << new_friend_email
    end
  end
  
  def order_details
    @session[:order_details] ||= {}
  end

  def was_invited?(friend)                                   
    # invite everyone by default
    return true unless order_details[:invited_user_attributes]
    # otherwise, only if they've been set by a previous call to record_order_details 
    order_details[:invited_user_attributes].include?(friend.email)
  end

  # Usually called by the controller to add the session persistent details
  # to the order model for the view
  def decorate_order(order)
    order.minutes_til_close = order_details[:minutes_til_close]
  end
    
end