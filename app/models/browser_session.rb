class BrowserSession
  
  def initialize(session)
    @session = session
  end                 

  def persist_order(order)
    forget :order
    p_order[:minutes_til_close] = order.minutes_til_close
    p_order[:invited_user_attributes] = order.invited_user_attributes
  end       
  
  def restore_order(order)
    order.minutes_til_close = p_order[:minutes_til_close]
    order.invited_user_attributes = p_order[:invited_user_attributes]
  end
  
  def forget label
    @session[:label] = nil
  end
  
  def p_order
    @session[:order] ||= {}
  end

end