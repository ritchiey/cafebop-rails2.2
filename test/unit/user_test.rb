require File.dirname(__FILE__)+'/../test_helper'

class UserTest < ActiveSupport::TestCase  

  context "a user" do
    setup do
      @user = User.make_unsaved
    end

    context "with a reputation of 0" do
      setup { @user.stubs(:reputation).returns(0) }
      should("be described as neutral") { assert_equal 'neutral', @user.reputation_s}
    end
    
    context "with a reputation of 1" do
      setup { @user.stubs(:reputation).returns(1) }
      should("be described correctly") { assert_equal 'positive +1', @user.reputation_s}
    end
    
    context "with a reputation of -10" do
      setup { @user.stubs(:reputation).returns(-10) }
      should("be described correctly") { assert_equal 'negative -10', @user.reputation_s}
    end
    
    
  end
  

  context "a user" do
    setup do
      @user = User.make 
      assert_not_nil @user
    end
    subject {@user}
  
    context "with an order" do
      
      setup do
        @order = Order.make_unsaved
      end
      
      context "that has been paid for" do
        setup do
          @order.stubs(:paid_at).returns(5.minutes.ago)
        end
        
        context "who doesn't show up" do
          setup do
            @user.no_show_for(@order)
          end

          should "not have his reputation changed" do
            assert_equal 0, @user.reputation
          end
        end
        
        context "who picks up the order" do
          setup do
            @user.picks_up(@order)
          end

          should "not have his reputation changed" do
            assert_equal 0, @user.reputation
          end
        end
        
      end
      context "with the default reputation of 0" do
        setup do
          assert_equal 0, @user.reputation
        end
      
      
     
        
        context "who doesn't show up" do
          setup do
            @user.no_show_for(@order)  
          end

          should "lose 4 reputation points" do
            assert_equal(-4, @user.reputation)
          end
        end
      
        context "who successfully picks up an order" do
          setup do
            @user.picks_up(@order)
          end

          should "gain 1 reputation point" do
            assert_equal 1, @user.reputation
          end
        end
      end
      
    
      context "with a reputation of -9" do
        setup do
          @user.reputation = -9
        end

        context "who doesn't show up" do
          setup do
            @user.no_show_for(@order)
          end

          should "be reduced to a -10 reputation" do
            assert_equal(-10, @user.reputation)
          end
        end
      
      end
    
      context "with a reputation of 10" do
        setup do
          @user.reputation = 10
        end

        context "who picks up an order" do
          setup do
            @user.picks_up(@order)
          end

          should "remain on a 10 reputation" do
            assert_equal 10, @user.reputation
          end
        end
      
      end
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
  
  
  context "Given a shop and a user" do
    setup do
      @shop = Shop.make
      @user = User.make
    end
        
    context "if the user becomes the manager of the shop" do
      setup do
        @user.becomes_manager_of(@shop)
      end

      before_should "not manage the shop" do
        assert !@user.manages?(@shop)
      end
      should "be the manager of the shop" do
        @user.reload
        assert @user.manages?(@shop)
      end
    end
    

    context "who is a patron of that shop" do
      setup do
        @user.becomes_patron_of(@shop)
        assert @user.is_patron_of?(@shop)
      end

      context "becomes the manager of the shop" do
        setup do
          @user.becomes_manager_of(@shop)
        end
        
        should "no longer be a patron" do
          @user.reload
          assert !@user.is_patron_of?(@shop)
          assert @user.manages?(@shop)
        end
      end
    end
    
  end
  

end
