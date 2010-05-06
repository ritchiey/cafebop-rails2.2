class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifications.send_later(:deliver_activate, user) unless user.active? or user.suppress_activation_email
  end
end
