class OrderObserver < ActiveRecord::Observer
  
  def after_create
    if @order.invited?
      Notifications.deliver_invite(user) unless RAILS_ENV == 'test'
    end
  end
  
  
  
end
