class ClaimObserver < ActiveRecord::Observer
  
  def after_create claim
    Notifications.deliver_new_claim claim
  end
end