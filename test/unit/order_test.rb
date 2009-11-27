require 'test_helper' 


class OrderTest < ActiveSupport::TestCase
  
  should_allow_mass_assignment_of :user, :order_item_attributes

  context "a new order" do
    
    setup do
      @order = Order.make
    end                  
    
    should "default to pending" do
      assert_equal "pending", @order.state
    end                                   
    
    should "have no order_items" do
      assert @order.order_items.empty?
    end
    
    should "not be in considered part of a group order" do
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

    context "and a user set and one child order" do
      setup do                 
        @order.user = User.make              
        @other_user = User.make
        @child_order = @order.invite(@other_user)
      end

      should "have respond correctly as parent and child" do
        assert @order.is_parent?
        assert !@order.is_child?
        assert !@child_order.is_parent?
        assert @child_order.is_child?
        assert @order.is_in_group?
        assert @child_order.is_in_group?
      end

      should "not be able to invite the same user again" do
        assert_no_difference "Order.count" do
          @order.update_attributes :invited_user_attributes=>[@other_user.email]
        end
      end
      
      should "be able to invite an exising user" do
        assert_difference "Order.count", 1 do                      
          email = User.make.email
          assert_not_nil email
          @order.update_attributes :invited_user_attributes=>[email]
        end
      end           
      
      should "have the same details on the child as the order" do
        assert_equal @order.shop, @child_order.shop
      end
      
    end
    
  end
  
  
end
