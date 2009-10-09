require File.dirname(__FILE__)+'/../test_helper'

class UserTest < ActiveSupport::TestCase  
  context "a user with the 'happy' role" do
    
    setup do
      @user = User.make 
      @user.add_role 'happy'
      assert_not_nil @user
      assert @user.is_happy?
    end      
    
    subject {@user}
  
    should_validate_uniqueness_of :email, :case_sensitive => false

    should "see an added role" do
      assert !@user.is_staff?
      @user.add_role 'staff'
      assert @user.is_staff?
      assert @user.is_happy?
    end     
    
    should "remove an added role" do
      @user.remove_role 'happy'
      assert !@user.is_happy?
    end         
    
    should "remove a role even if it has been added twice" do
      assert @user.is_happy?
      @user.add_role 'happy'
      @user.remove_role 'happy'
      assert !@user.is_happy?
    end
    
  end
end
