require 'test_helper'   
require 'interactions'

class GroupOrderTest < ActionController::IntegrationTest
  setup :activate_authlogic 
  
  include Interactions

  def setup
    password = "quiddich"
    @harry_user = User.make(:active=>true, :email=>"harry@hogwarts.edu", :password=>password, :password_confirmation=>password)
    @harry = as(@harry_user.email, password)
    @ron_user = User.make(:active=>true, :email=>"ron@hogwarts.edu", :password=>password, :password_confirmation=>password)
    @ron = as(@ron_user.email, password)
  end
  
  # def test_group_order
  #   order = @harry.creates_an_order
  #   @harry.invites @ron_user.email, :to=>order
  #   @ron.accepts_invitation_sent_to(@ron_user)
  # end
  
end