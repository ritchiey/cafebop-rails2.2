class Notifications < ActionMailer::Base

  def activate(user)
    subject    'Please activate your account'
    recipients user.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :activation_url => activate_url(:token => user.perishable_token)
  end

  def invite(order)                        
    parent = order.parent
    subject    "Want anything from #{parent.shop}?"
    recipients order.user.email
    from       SUPPORT_EMAIL
    reply_to   parent.user.email
    sent_on    Time.now
    body   :order => order,
           :parent => parent,
           :accept_url => accept_orders_url(:token => order.perishable_token),
           :decline_url => decline_orders_url(:token => order.perishable_token)  
  end
  
  def claim_confirmed(claim)
    subject    "Your claim for #{claim.shop}"
    recipients claim.user.email
    from       CLAIMS_EMAIL
    sent_on    Time.now
    body       :claim=>claim
  end

  def claim_rejected(claim)
    subject    "Your claim for #{claim.shop}"
    recipients claim.user.email
    from       CLAIMS_EMAIL
    sent_on    Time.now
    body       :claim=>claim
  end

end
