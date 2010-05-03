require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  
  context "Specifying menu_data when creating a shop" do
    setup do
      @shop = Shop.make(:name=>'blah', :menu_data=>@menu_data)
    end

    before_should "cause the menu to be imported" do
      @menu_data =<<END
Menu,Item Name,Description,Prices,Flavours

Curry
,Green Curry,"choice of chicken, beef or pork",15.9,"Chicken, Beef, Pork"
END
      Menu.expects(:import_csv).with("", @menu_data, anything).once
    end
  end
  
  context "a newly created shop" do
    setup do
      @shop = Shop.make
    end

    should "be inactive" do
      assert !@shop.active?
    end
    
    context "given the correct activation code" do
      setup do
        @shop.activation_confirmation = @shop.activation_code
      end

      should "become active" do
        assert @shop.active?
      end
    end
    
    context "given an incorrect activation code" do
      setup do
        @shop.activation_confirmation = 'strawberries'
      end

      should "remain inactive" do
        assert !@shop.active?
      end
    end
    
  end
  

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
    
    should "not be able to take online payment" do
      assert !@shop.accept_paypal_orders
    end
    
    should "not have a paypal recipient by default" do
      assert_nil @shop.paypal_recipient
    end             
    
    should "default to express" do
      assert @shop.express?
      assert !@shop.professional?
    end
    
    should "switch to professional when told" do
      assert @shop.express?
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
  
  
  

end
