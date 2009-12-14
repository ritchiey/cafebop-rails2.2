require 'test_helper' 


class OrderTest < ActiveSupport::TestCase
  
  should_allow_mass_assignment_of :user, :order_item_attributes

  context "a new order" do
    
    setup do
      @order = Order.make
    end                  
    
    should "be able to send invites" do
      assert @order.can_send_invites?
    end
    
    should "not have it's timer started" do
      assert !@order.close_timer_started?
    end
    
    should "default to pending" do
      assert_equal "pending", @order.state
    end                                   
    
    should "have no order_items" do
      assert @order.order_items.empty?
    end
    
    should "not be considered part of a group order" do
      assert !@order.is_in_group?
    end                         
    
    should "not be a child" do
      assert !@order.is_child?
    end                       
    
    should "not be a parent" do
      assert !@order.is_parent?
    end
    
  end
  
  context "an order with a few order_items" do
    
    setup do
      @order = Order.make
      (1..3).each do |i|
        menu_item = MenuItem.make(:price_in_cents=>100)
        OrderItem.make(:order=>@order, :quantity=>i, :menu_item=>menu_item)
      end
      assert_equal 3, @order.order_items.length
    end
    
    should "calculate total correctly" do
      assert_equal 6.00, @order.total
    end

    should "print all its order_items on pay_in_shop if shop doesn't queue pay in shop items" do
      @order.order_items.each {|item| assert item.pending?}
      class << @order.shop
        def queues_in_shop_payments?() false; end
      end
      @order.send 'print_or_queue!'
      assert @order.printed?
      @order.order_items.each {|item| assert item.printed?}
    end


    context "for a shop that queues pay-in-shop items" do
      setup do
        class << @order.shop
          def queues_in_shop_payments?() true; end
        end
      end     
      
      context "when queued" do
        setup do
          @order.order_items.each {|item| assert item.pending?}
          @order.send 'print_or_queue!'
          assert @order.queued?
        end
    
        should "queue all its order_items" do
          @order.order_items.each {|item| assert item.queued?}
        end   
                                               
        should "transition from queued to made on make!" do
          assert @order.queued?
          @order.make!
          assert @order.made?
        end
      
        should "transition to made when last order_item is made" do
          assert @order.queued?
          @order.order_items.each do |item|
            assert_equal @order, item.order
            assert item.queued?
            item.make!
            assert @order.queued?
            assert item.made?
            if @order.order_items.any? {|item| !item.made?}
              assert @order.queued?
            else  
              @order.reload
              assert @order.made?
            end
          end
          assert @order.order_items.all? {|item| item.made?}
          @order.reload
          assert @order.made?, "order should have been made"
        end

      end
      
    end

    context "and a user set" do
      setup do
        @user = User.make(:active)
        assert @order.user = @user
        assert @order.save
      end
      
      context "who has friends" do
        setup do
          assert_difference "@user.friends.count", 1 do
            @friend = User.make
            assert @user.friends << @friend
            @user.save
          end
        end

        should "invite the friend by default" do
          @order.will_invite?(@friend)
        end
        
        should "include the user in the list to invite" do
          assert_same_elements [@friend], @order.possible_invitees
        end
        
        should "show the friends email as a possible invitee" do
          assert_same_elements [@friend], @order.possible_invitees
        end
      end
      
    
      should "invite new users when saved" do
        @current_user = User.make
        @new_user_email = 'hagrid@cafebop.com'
        assert_difference "Order.count", 2 do
          assert_difference "User.count", 1 do
            @order.attributes = {:start_close_timer=>"true", :invited_user_attributes=>[@new_user_email, @current_user.email]}
            assert @order.save
          end
        end
        assert_not_nil( @new_user = User.find_by_email(@new_user_email))
        assert_equal @order, @current_user.orders.find(:last).parent
        assert_equal @order, @new_user.orders.find(:last).parent
      end                                                
      
      context "and two child orders one of which is confirmed" do
        setup do                 
          @other_user = User.make(:email=>'other@cafebop.com')
          assert_difference "@order.child_orders.count", 1 do
            @child_order = @order.invite(@other_user)
          end
          @child_order.accept! 
          # make an order_item but don't confirm the order so it shouldn't count
          @child_order.order_items.make
          @other_user_confirmed = User.make(:email=>'confirmed@cafebop.com')
          assert_difference "@order.child_orders.count", 1 do
            @child_order_confirmed = @order.invite(@other_user_confirmed)
          end
          @child_order_confirmed.accept!
          @child_order_confirmed.order_items.make
          assert_difference "@order.child_orders.state_eq('confirmed').count", 1 do
            @child_order_confirmed.confirm!
          end
        end
        
        should "respond correctly as parent and child" do
          assert @order.is_parent?, "Order not recognised as parent"
          assert !@order.is_child?, "Order thinks it's a child"
          assert !@child_order.is_parent?, "Child order thinks its a parent"
          assert @child_order.is_child?, "Child order doesn't think it's  child"
          assert @order.is_in_group?, "Order doesn't realise its in a group"
          assert @child_order.is_in_group?, "Child order doesn't realise it's in a group"
        end

        should "not be able to invite the same user again" do
          assert_same_elements [@other_user, @other_user_confirmed], @order.invited_users.all
          assert_no_difference "Order.count" do
            @order.update_attributes :invited_user_attributes=>[@other_user.email]
          end
        end
      
        should "be able to invite an exising user" do
          assert_difference "Order.count", 1 do                      
            email = User.make.email
            assert_not_nil email
            @order.update_attributes :start_close_timer=>'true', :invited_user_attributes=>[email]
          end
        end           
      
        should "have the same details on the child as the order" do
          assert_not_nil @order.shop
          assert_equal @order.shop, @child_order.shop
        end 
        
        context "for a shop that queues pay-in-shop items" do
          setup do
            class << @order.shop
              def queues_in_shop_payments?() true; end
            end
          end     

          context "when queued" do
            setup do
              @order.order_items.each {|item| assert item.pending?}
              @order.send 'print_or_queue!'
              assert @order.queued?
            end

            should "queue all its order_items" do
              @order.order_items.each {|item| assert item.queued?}
            end           
            
            should "queue all its confirmed child_orders order items" do
              @child_order_confirmed.order_items.each {|item| assert item.queued?}
            end

            should "not queue any of its unconfirmed child_orders order items" do
              @child_order.order_items.each {|item| assert !item.queued?}
            end

            should "transition from queued to made on make!" do
              assert @order.queued?
              @order.make!
              assert @order.made?
            end

            should "transition to made when last order_item is made" do
              assert @order.queued?
              @order.order_items.each do |item|
                assert_equal @order, item.order
                assert item.queued?
                item.make!
                assert @order.queued?
                assert item.made?
                if @order.order_items.any? {|item| !item.made?}
                  assert @order.queued?
                else  
                  @order.reload
                  assert @order.made?
                end
              end
              assert @order.order_items.all? {|item| item.made?}
              @order.reload
              assert @order.made?, "order should have been made"
            end

          end

        end        
      
      end

    end
  end

  
  context "an old order and a new order" do
    setup do
      @old_order = Order.make
      @old_order.created_at = 1.year.ago
      @old_order.save
      @new_order = Order.make
    end

    should "be correctly distinguished by the recent named_scope" do
      assert_same_elements [@new_order], Order.recent.all
    end
    
    should "appear in the right order" do
      assert_equal [@new_order, @old_order], Order.newest_first.all
    end
  end
  
end
