class ClaimObserver < ActiveRecord::Observer
  
  def after_create claim
    Notifications.send_later(:deliver_new_claim, claim)
  end
end