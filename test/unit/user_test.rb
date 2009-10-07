require File.dirname(__FILE__)+'/../test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.make
  end
  
  should_validate_uniqueness_of :email, :case_sensitive => false
end
