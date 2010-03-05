require 'test_helper' 


class OrderTest < ActiveSupport::TestCase
  
  should_allow_mass_assignment_of :user, :order_item_attributes



  context "a new order" do
    
    setup do
      @order = Order.make
    end        
    
    should "create and set the user when user email is set to a non-existant user" do
      @order.user_email = "somenewguy@cafebop.com"
      assert_difference "User.count", 1 do
        assert @order.save
      end
      @order.reload
      assert_not_nil @order.user
    end          
    
    should "be its own group" do
      assert_equal @order, @order.group
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
    
    should "remove an order item when instructed" do
      assert_difference "@order.order_items.count", -1 do
        items = @order.order_items.all.map do |item|
          {"menu_item_id"=>item.menu_item_id, "quantity"=>item.quantity, "flavour_id"=>item.flavour_id, "size_id"=>item.size_id, "id"=>item.id}
        end
        items[1]['_delete'] = 1
        @order.update_attributes(:order_items_attributes=>items)
      end
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

    should "be able to be queued" do
      assert @order.can_be_queued?
    end

    context "for a shop that queues pay-in-shop items" do
      setup do
        @order.shop.stubs(:queues_in_shop_payments?).returns(true)
      end     
      
      context "when queued" do
        setup do
          @order.order_items.each {|item| assert item.pending?}
          @order.send 'print_or_queue!'
        end                   
        
        should "queue all its order_items" do
          assert @order.queued?
          @order.order_items.each {|item| assert item.queued?}
        end   
                                             
        should "transition from queued to made on make!" do
          assert @order.queued?
          @order.make!
          assert @order.made?
        end
        
        should "be able to record a no_show" do
          @order.user.expects(:no_show_for).with(@order).once
          assert !@order.cancelled?
          @order.no_show!
          assert @order.cancelled?
        end

        should "call make on each order_item on make_all_items" do
          assert @order.order_items.all.all? {|item| item.queued?}
          @order.make_all_items!
          assert @order.order_items.all.all? {|item| item.made?}
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
      

      should "be able to be queued" do
        assert @order.can_be_queued?
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
        
        should "calculate the grand_total correctly" do
          expected = @order.total + @child_order_confirmed.total
          assert expected > 0
          assert expected > @order.total
          assert_equal expected, @order.grand_total
        end
        
        should "all have the correct group" do
          assert_equal @order, @order.group
          assert_equal @order, @child_order.group
          assert_equal @order, @child_order_confirmed.group
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
              @child_order_confirmed.reload
              @child_order_confirmed.order_items.each {|item| assert item.queued?}
            end

            should "not queue any of its unconfirmed child_orders order items" do
              @child_order.reload
              @child_order.order_items.each {|item| assert !item.queued?}
            end         
            
            should "not allow the unconfirmed order to confirm" do
              assert_no_difference "@order.confirmed_child_order_items.count" do
                @child_order.reload
                @child_order.confirm!
              end
            end            
            
            should "not allow the confirmed child order to add more items" do
              assert_no_difference "@child_order_confirmed.order_items.count" do
                begin
                  @child_order_confirmed.order_items.make
                  @child_order_confirmed.save
                rescue Exception => e
                end
              end
            end

            should "transition to made when last order_item is made" do
              assert @order.queued?
              @order.order_items.each do |item|
                assert_equal @order, item.order
                assert item.queued?
                item.make!
                assert item.made?
              end
              @order.reload
              assert @order.order_items.all? {|item| item.made?}
              @child_order_confirmed.reload
              assert @child_order_confirmed.confirmed?
              assert @order.queued? # shouldn't be made because the child items haven't been
              @order.confirmed_child_order_items.each do |item|
                assert item.queued?
                item.make!
                assert item.made?
              end
              @order.reload
              assert @order.made?, "order should have been made"
              @child_order_confirmed.reload
              assert @child_order_confirmed.made?, "child order should have been flagged as made"
            end

            should "only transition to made when the parent is made" do 
              assert @order.queued?
              assert @child_order_confirmed.confirmed?
              @order.confirmed_child_order_items.each do |item|
                assert item.queued?
                item.make!
                assert item.made?
              end
              @order.reload
              assert @order.confirmed_child_order_items.all? {|item| item.made?}
              @child_order_confirmed.reload
              assert @child_order_confirmed.confirmed?
              assert @order.queued? # shouldn't be made because the child items haven't been
              @order.order_items.each do |item|
                assert_equal @order, item.order
                assert item.queued?
                item.make!
                assert item.made?
              end
              @order.reload
              assert @order.made?, "order should have been made"
              @child_order_confirmed.reload
              assert @child_order_confirmed.made?, "child order should have been flagged as made"
            end

            context "then made" do
              setup do
                assert @order.queued?
                @order.make!
                @order.reload
              end
              
              should "be made" do
                assert @order.made?
              end
              
              should "cause it's confirmed child_orders to be made" do
                @child_order_confirmed.reload
                assert @child_order_confirmed.made?
              end
              
              should "still calculate the grand_total correctly" do
                expected = @order.total + @child_order_confirmed.total
                assert expected > 0
                assert expected > @order.total
                assert_equal expected, @order.grand_total
              end

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
  
  
  context "An order with a 1% commission" do
    setup do
      @order = Order.make
      @order.stubs(:commission_rate).returns(0.01)
      assert_equal 0.01, @order.commission_rate
    end
                                                  

    should "calculate correct commission and net total values" do
      [
        [100.00, 1.00, 99.00],
        [99.99, 1.00, 98.99],
        [3.80, 0.04, 3.76]
      ].each do |row|
        expected_total, commission, net_total = *row
        @order.stubs(:grand_total).returns(expected_total)
        assert_equal expected_total, @order.grand_total
        assert_equal commission, @order.commission
        assert_equal net_total, @order.net_total
        assert_equal expected_total, @order.net_total + @order.commission
      end
    end

  end
  
end
