class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifications.deliver_activate(user)
  end
end
