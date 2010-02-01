require 'test_helper'

class CuisineTest < ActiveSupport::TestCase
  
  context "A couple of cuisines" do
    setup do
      @cuisine = Cuisine.make
      @franchise = Cuisine.make(:franchise=>true)
    end
    
    should "appear in the correct searches" do
      assert_same_elements [@cuisine], Cuisine.is_not_franchise
      assert_same_elements [@franchise], Cuisine.is_franchise
    end
                              
  end
  
  context "A cuisine with a regex" do
    setup do
      @cuisine = Cuisine.make(:regex=>'coffee|cafe')
      assert_equal 'coffee|cafe', @cuisine.regex
    end

    should "match names appropriately" do
      assert @cuisine.matches_name("Bob's Cafe")
      assert @cuisine.matches_name("Bob's Coffee Shop")
      assert !@cuisine.matches_name("Bob's Pizzeria")
    end
  end

  context "A bunch of cuisines" do
    setup do
      @cafe = Cuisine.make(:name=>'Cafe', :regex=>'coffee|cafe')
      @pizzeria = Cuisine.make(:name=>'Pizza', :regex=>'pizza|pizzeria')
      @pasta = Cuisine.make(:name=>'Pasta')
      @death = Cuisine.make(:name=>'Death', :regex=>'')
      @disaster = Cuisine.make(:name=>'Disaster', :regex=>'(incomlet')
      @calamity = Cuisine.make(:name=>'Calamity')
    end
    
    
    should "match names appropriately" do
      assert_same_elements [@cafe, @pizzeria], Cuisine.matching_name("Bob's Pizzas and Coffee")
      assert_same_elements [@cafe], Cuisine.matching_name("The Imp Cafe")
      assert_same_elements [@pasta], Cuisine.matching_name("Eugene's Pasta")
      assert_same_elements [], Cuisine.matching_name("Head on a Stick")
    end
    
    context "and a couple of franchises" do
      setup do
        @hahns = Cuisine.make(:name=>"Hahn's Cafe", :franchise=>true)
        @punch = Cuisine.make(:name=>"Punch Cafe", :franchise=>true)
      end

      should "return appropriate matching patterns" do
        assert_equal "Punch Cafe", @punch.matching_pattern
        assert_equal "Hahn's Cafe", @hahns.matching_pattern
      end

      should "stop searching if it matches the franchise name" do
        assert_same_elements [@punch], Cuisine.matching_name("Punch Cafe East Perth")
        assert_same_elements [@hahns], Cuisine.matching_name("Hahn's Cafe")
      end
    end
    
    
  end
  
end
