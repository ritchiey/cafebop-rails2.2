class BrowserSession
  
  def initialize(session)
    @session = session
  end                 

  def add_invite_details(params)
    %w/email minutes_til_closes invitees/.each do |attrib|
      session["invite_#{attrib}"] = params[attrib]
    end
  end
  
  def method_missing m
    session[m]
  end
    
end