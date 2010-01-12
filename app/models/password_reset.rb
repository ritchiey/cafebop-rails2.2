class PasswordReset < ActiveRecord::Base
   
  def self.columns() @columns ||= []; end  
   
  def self.column(name, sql_type = nil, default = nil, null = true)  
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)  
  end  
  
  column  :email, :string      
  column  :password, :string
  column  :password_confirmation, :string
  column  :token, :string
  
  attr_accessor :user

  def id
    @user && @user.perishable_token
  end                              
  
  def new_record?
    !@user or @user.new_record?
  end

  def deliver_password_reset_instructions!
    @user = User.find_by_email(email)
    if @user
      @user.deliver_password_reset_instructions!
    end
  end
    
  def save
      @user.password = password
      @user.password_confirmation = password_confirmation
      @user.save
  end
  
  
  def self.find_using_perishable_token(token)
    if user = User.find_using_perishable_token(token, 4.hours)
      self.new(:token=>token, :email=>user.email).tap do |pr|
        pr.user = user
      end
    end
  end
    
end