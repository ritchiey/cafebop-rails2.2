class OrderObserver < ActiveRecord::Observer
  
  def after_create order
    order.invited? and Notifications.deliver_invite(order)
    
    if user = order.user
      user.work_contracts.find_or_create_by_shop_id(order.shop_id)
    end
  end
  
  
  
  
end
