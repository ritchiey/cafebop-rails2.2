require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase

  context "Specifying manager_email when creating a shop" do
    setup do
      @email = "bob@test.com"
      @shop = Shop.make(:manager_email=>"bob@test.com")
    end

    should "create an express shop" do
      assert @shop.express?
    end
    
    should "create a user and manager role for the email" do
      user = User.find_by_email(@email)
      assert user
      assert user.manages?(@shop)
    end
    
    should "make email the paypal recipient for the shop" do
      assert_equal(@shop.paypal_recipient, @email)
    end
    
    should "make the required queues" do
      assert_equal 1, @shop.customer_queues.count
      assert_equal 1, @shop.item_queues.count
    end
  end
  

  context "a shop" do
    setup do
      @shop = Shop.make
    end   
    
    should "update its counter cache when voted for" do
      assert_difference "@shop.votes_count", 1 do
        @shop.votes.create
        @shop.reload
      end
    end
    
    should "not have a paypal recipient by default" do
      assert_nil @shop.paypal_recipient
    end             
    
    should "not be able to enable queuing" do
      assert !@shop.accepts_queued_orders?
      @shop.start_accepting_queued_orders!
      @shop.reload
      assert !@shop.accepts_queued_orders?
    end
    
    should "default to community managed" do
      assert @shop.community?
      assert !@shop.express?
      assert !@shop.professional?
    end
    
    should "switch to express when told" do
      assert @shop.community?
      @shop.go_express!
      assert @shop.express?
    end

    should "switch to professional when told" do
      assert @shop.community?
      @shop.go_professional!
      assert @shop.professional?
    end

    context "with a given cuisine" do
      setup do
        @cuisine = Cuisine.make
        @shop.cuisines << @cuisine
      end                        
      
      should "appear to have that cuisine"  do
        assert_equal [@cuisine], @shop.cuisines.all
      end                                          
      
      should "appear in the list of shops with_cuisine(@cuisine)" do
        other_shop = Shop.make
        assert_equal [@shop], Shop.with_cuisine(@cuisine)
      end
      
      should "appear in a search for that shop with that cuisine" do
        search = Search.new(:cuisine=>@cuisine.id.to_s, :term=>@shop.name)
        assert_equal [@shop], search.shops 
      end
      
      # Disabled search by cuisine for now due to limitation of the postgresql driver
      # should "not appear in a search for that shop name but a different cuisine" do
      #   search = Search.new(:cuisine=>Cuisine.make.id.to_s, :term=>@shop.name)
      #   assert_equal [], search.shops
      # end
      
    end
       
  end
   
  context "a community shop " do
    setup do
      @shop = Shop.make
      assert @shop.community?
    end
    
    should "only be claimable by a an appropriate user" do
      user = User.make
      assert @shop.can_be_claimed_by?(user) 
      assert @shop.claims.make(:user=>user)  
      @shop.reload
      user.reload
      assert !@shop.can_be_claimed_by?(user)
      claim = @shop.claims.make_unsaved(:user=>user)
      assert !claim.save
    end
    
    context "that is claimed by an existing patron" do
      setup do
        @user = User.make(:active)
        assert_difference "@shop.patrons.count", 1 do
          @user.work_contracts.find_or_create_by_shop_id(@shop.id)
        end                           
        assert_no_difference "@user.work_contracts.count" do
          @shop.claim!(@user)
        end
      end

      should "have that user as its manager only" do
        assert_same_elements [@user], @shop.managers
        assert_same_elements [], @shop.patrons
      end
    end
    

    context "with a given cuisine" do
      setup do
        @cuisine = Cuisine.make(:name=>"Chicken")
        @shop.cuisines << @cuisine
        @menu = Menu.make(:name=>"Roast Chicken", :shop=>nil, :cuisines=>[@cuisine])
        assert_equal [@menu], @cuisine.menus.all
        assert_equal [@shop], @cuisine.shops
      end

      should "see the menus for that cuisine as virtual_menus" do
        assert_equal [@menu], Menu.virtual_for_shop(@shop)
        assert_equal [@menu], @shop.effective_menus
      end

      should "not have any menus" do
        assert @shop.menus.empty?
      end

      context "which goes express" do
        setup do
          @shop.go_express!
          @shop.reload
        end

        should "get a copy of the virtual menus" do
          assert_equal @shop.virtual_menus.*.name, @shop.menus.*.name
          assert_not_equal @shop.virtual_menus.*.id, @shop.menus.*.id
        end
        
        should "be able to enable queuing" do
          assert !@shop.accepts_queued_orders?
          @shop.start_accepting_queued_orders!
          @shop.reload
          assert @shop.accepts_queued_orders?
        end

        should "not be able to enable paypal because queues aren't enabled" do
          assert !@shop.accepts_queued_orders?
          assert !@shop.accepts_paypal_payments?
          @shop.enable_paypal_payments!
          @shop.reload
          assert !@shop.accepts_paypal_payments?
        end

      end
    end
    
  end

  
  context "With a bunch of cuisines" do
    setup do
      @cafe = Cuisine.make(:name=>'Cafe', :regex=>'coffee|cafe')
      @pizzeria = Cuisine.make(:name=>'Pizza', :regex=>'pizza|pizzeria')
      @pasta = Cuisine.make(:name=>'Pasta')
    end

    context "a new shop" do
      setup do
        @shop = Shop.make(:name=>"Bob's Pizza Palace")
      end

      should "automatically get the right cuisine" do
        assert_same_elements [@pizzeria], @shop.cuisines
      end
    end
    
  end
  
  
  context "Given 3 shops" do
    setup do
      @shop1 = Shop.make
      @shop2 = Shop.make
      @shop3 = Shop.make
    end

    context "the most voted for" do
      setup do
        2.times { @shop1.votes.create}
        3.times { @shop2.votes.create}
        1.times { @shop3.votes.create}
        [@shop1, @shop2, @shop3].each {|s| s.reload}
      end

      should "have the top ranking" do
        assert_equal 1, @shop2.ranking
        assert_equal 2, @shop1.ranking
        assert_equal 3, @shop3.ranking
      end
    end
    
  end
  

end
