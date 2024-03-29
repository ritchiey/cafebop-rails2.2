class Notifications < ActionMailer::Base

  def activate(user)
    subject    'Please activate your account'
    recipients user.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :activation_url => activate_url(:token => user.perishable_token)
  end

  def activate_shop shop
    subject    'Activation code for your new shop'
    recipients shop.owner.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :shop => shop
  end

  def invite(order)                        
    parent = order.parent
    subject    "Want anything from #{parent.shop}?"
    recipients order.user.email
    from       ORDERING_EMAIL
    reply_to   parent.user.email
    sent_on    Time.now
    body   :order => order,
           :parent => parent,
           :accept_url => accept_orders_url(:token => order.perishable_token),
           :decline_url => decline_orders_url(:token => order.perishable_token)  
  end

  def welcome(user)
    subject    'Welcome to Cafebop'
    recipients user.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :root_url => root_url,
                :feedback_email => FEEDBACK_EMAIL
  end
  
  def child_order_made(order)
    subject    "Your #{order.shop} order is ready"
    recipients order.user.email
    from       ORDERING_EMAIL
    sent_on    Time.now
    body       :order=>order
  end

  def order_made(order)
    subject    "Your #{order.shop} order is ready"
    recipients order.user.email
    from       ORDERING_EMAIL
    sent_on    Time.now
    body       :order=>order, :user=>order.user, :shop=>order.shop
  end
  
  def order_cancelled(order)
    subject    "Your #{order.shop} order has been cancelled"
    recipients order.user.email
    from       ORDERING_EMAIL
    sent_on    Time.now
    body       :order=>order
  end     
  
  def queuing_enabled(shop)
    subject    "Queuing enabled for #{shop}"
    recipients shop.managers.*.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :shop=>shop
  end
    
  def queuing_disabled(shop)
    subject    "Queuing disabled for #{shop}"
    recipients shop.managers.*.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :shop=>shop
  end
  
  def paypal_enabled(shop)
    subject    "PayPal enabled for #{shop}"
    recipients shop.managers.*.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :shop=>shop
  end
  
  def paypal_disabled(shop)
    subject    "PayPal disabled for #{shop}"
    recipients shop.managers.*.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :shop=>shop
  end       


  def password_reset_instructions user
    subject       "Password Reset Instructions"  
    from          SUPPORT_EMAIL
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
    
end
