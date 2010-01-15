module OrderInvitation

                    
  def minutes_til_close
    self[:minutes_til_close] || 10
  end

  def start_close_timer
    "yes" # the default value that will appear on forms.
    # internally, we'll check the instance variable instead
  end
    
  def start_close_timer=(value)
    @start_close_timer = value
  end                   
  
  def close_time
    is_child? ? parent.close_time : self[:close_time]
  end
  
  def closed?
    Time.now >= close_time
  end
  
  def waiting_for_close?
    close_timer_started? and !closed?
  end     
  
  def close_timer_started?
    close_time
  end
  
  
  # These are the emails of the users that are to be invited when
  # the user is saved. Those not already invited (ie in invited_users)
  # will be invited
  def invited_user_attributes=(emails)
    @invited_user_attributes = emails
  end                       

  def invited_user_attributes
    @invited_user_attributes ||= possible_invitees.*.email
  end                       
  
  def possible_invitees
    user ? user.friends : []
  end
  
  def will_invite?(user)      
    invited_user_attributes.include?(user.email)
  end                                        
  
  def have_invited?(user)
    invited_users.include?(user)
  end
  
  def invitee?(user)
    will_invite?(user) or have_invited?(user)
  end
  
  # Can only send invites if not a child order
  def can_send_invites?
    !is_child? and !close_timer_started?
  end
   
private

  def valid_email email
    email_regex = %r{
      ^ # Start of string

      [0-9a-z] # First character
      [0-9a-z.+]+ # Middle characters
      [0-9a-z] # Last character

      @ # Separating @ character

      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end

      $ # End of string
    }xi # Case insensitive
    email =~ email_regex
  end
  
end