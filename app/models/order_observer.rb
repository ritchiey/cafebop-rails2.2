class OrderObserver < ActiveRecord::Observer
  
  def after_create order
    order.invited? and Notifications.send_later(:deliver_invite, order)
    
    if user = order.user
      user.add_favourite(order.shop_id)
    end
  end        
  
  
  def after_save order
    case order.changes['state']
    when ['confirmed', 'made']
      RAILS_DEFAULT_LOGGER.info "Child order #{order.id} has been made."
      Notifications.send_later(:deliver_child_order_made, order) if order.user
    when ['queued', 'made']
      RAILS_DEFAULT_LOGGER.info "Order #{order.id} has been made."
      Notifications.send_later(:deliver_order_made, order) if order.user
    when ['queued', 'cancelled']
      RAILS_DEFAULT_LOGGER.info "Order #{order.id} has been cancelled."
      Notifications.send_later(:deliver_order_cancelled, order) if order.user
    end
    
    # update details in user record for next time
    user = order.user
    if user and order.changes.keys.any? {|k| [:name, :phone, :address].include?(k.to_sym)}
      user.name = order.name if order.name_changed?
      user.phone = order.phone if order.phone_changed?
      user.address = order.address if order.address_changed?
      user.save
    end
  end
  
end
