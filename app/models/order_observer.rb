class OrderObserver < ActiveRecord::Observer
  
  def after_create order
    order.invited? and Notifications.deliver_invite(order)
    
    if user = order.user
      user.work_contracts.find_or_create_by_shop_id(order.shop_id)
    end
  end        
  
  
  def after_save order
    case order.changes['state']
    when ['queued', 'made']
      RAILS_DEFAULT_LOGGER.info "Order #{order.id} has been made."
      Notifications.deliver_order_made(order) if order.user
    when ['queued', 'cancelled']
      RAILS_DEFAULT_LOGGER.info "Order #{order.id} has been cancelled."
      Notifications.deliver_order_cancelled(order) if order.user
    end
  end
  
end
