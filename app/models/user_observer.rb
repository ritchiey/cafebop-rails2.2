class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifications.send_later(:deliver_activate, user) unless user.active?
  end
end
