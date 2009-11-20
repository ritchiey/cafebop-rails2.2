class OrderObserver < ActiveRecord::Observer
  
  def after_create order
    order.invited? and Notifications.deliver_invite(order)
  end
  
  
  
end
