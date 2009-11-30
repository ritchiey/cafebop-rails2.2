require File.dirname(__FILE__)+'/../test_helper'

class UserTest < ActiveSupport::TestCase  

  context "a user" do
    setup do
      @user = User.make 
      assert_not_nil @user
    end
    subject {@user}
  
    should_validate_uniqueness_of :email, :case_sensitive => false

    context "with the 'happy' role" do
      setup do
        @user.add_role 'happy'
        assert @user.is_happy?
      end      

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
    
    context "that manages a shop" do
      setup do                          
        @my_shop = Shop.make             
        WorkContract.make(:user=>@user, :shop=>@my_shop, :role=>'manager')
        @other_shop = Shop.make
        @other_shop_worked_at = Shop.make
        WorkContract.make(:user=>@user, :shop=>@my_shop, :role=>'staff')
      end

      should "only manage his own shop" do
        assert @user.manages?(@my_shop)
        assert !@user.manages?(@other_shop)
        assert !@user.manages?(@shop_worked_at)
      end
      
    end

    should "be added to the list by for_users alongside a previously non-existent user" do
      newguy_email = "newguy@cafebop.com"
      users = nil
      assert_difference "User.count", 1 do
        users = User.for_emails([@user.email, newguy_email])
      end
      assert_not_nil newguy = User.find_by_email(newguy_email)
      assert_same_elements [@user, newguy], users
    end

  end



end
