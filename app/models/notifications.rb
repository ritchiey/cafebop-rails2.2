class Notifications < ActionMailer::Base

  def activate(user)
    subject    'Please activate your account'
    recipients user.email
    from       SUPPORT_EMAIL
    sent_on    Time.now
    body       :activation_url => activate_url(:token => user.perishable_token)
  end

end
