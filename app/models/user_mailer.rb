class UserMailer < ActionMailer::Base

  def order_invitation(order, key, host='cafebop.com', app_name='Cafebop')
    invitee = order.user
    invitor = order.parent.user
    shop = order.shop
    subject "I'm going to #{shop}. Want anything?"
    recipients invitee.email_address
    from       invitor.email_address
    sent_on    Time.now
    body :order=>order,
      :invitor => invitor,
      :shop=>shop,
      :invitee=>invitee,
      :key=>key, :host=>host,
      :app_name=>app_name
  end

  def forgot_password(user, key)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host
    @subject    = "#{app_name} -- forgotten password"
    @body       = { :user => user, :key => key, :host => host, :app_name => app_name }
    @recipients = user.email_address
    @from       = "no-reply@#{host}"
    @sent_on    = Time.now
    @headers    = {}
  end


  def activation(user, key)
    host = Hobo::Controller.request_host
    @subject = "#{app_name} -- activate"
    @body = { :user=>user, :key=>key, :host=>host, :app_name=>app_name }
    @recipients = user.email_address
    @from = "no-reply@cafebop.com"
    @sent_on = Time.now
    @headers = {}
  end

  private
  def app_name
    "Cafebop"
  end
end
