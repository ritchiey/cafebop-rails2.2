class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifications.deliver_activate(user) unless RAILS_ENV == 'test'
  end
end
