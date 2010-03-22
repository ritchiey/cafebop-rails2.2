require File.dirname(__FILE__)+'/../test_helper'

class UserTest < ActiveSupport::TestCase  

  context "a user" do
    setup do
      @user = User.make 
      assert_not_nil @user
    end
    subject {@user}
  
    should "have a no_show_for method" do
      assert @user.respond_to?(:no_show_for)
    end
  
    should_validate_uniqueness_of :email, :case_sensitive => false

    should("not be signed up by default") {assert !@user.signed_up?}
    
    context "that signs up" do
      setup do
        @user.sign_up!
      end

      should("be signed_up") {assert @user.signed_up?}
    end
    

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
        @user.work_contracts.make(:shop=>@other_shop_worked_at, :role=>'staff')
        assert @user.works_at?(@other_shop_worked_at)
      end

      should "be considered to work at the shop" do
        assert @user.works_at?(@my_shop)
      end                           
      
      should "only manage his own shop" do
        assert @user.manages?(@my_shop)
        assert !@user.manages?(@other_shop)
        assert !@user.manages?(@shop_worked_at)
      end
      
      should "not create another work_contract for his own restaurant" do
        assert_no_difference "@user.work_contracts.count" do
          @user.add_favourite(@my_shop.id)
        end
        assert @user.manages?(@my_shop)
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

  context "A user with a given email" do
    setup do
      @user = User.make(:email=>'hagrid@cafebop.com')
    end

    should "have an appropriate shortened email" do
      assert_equal 'hagrid', @user.shortened_email
    end
  end
  

end
