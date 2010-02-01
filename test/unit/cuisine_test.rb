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

  context "With a bunch of cuisines" do
    setup do
      @cafe = Cuisine.make(:name=>'Cafe', :regex=>'coffee|cafe')
      @pizzeria = Cuisine.make(:name=>'Pizza', :regex=>'pizza|pizzeria')
      @pasta = Cuisine.make(:name=>'Pasta')
      @death = Cuisine.make(:name=>'Death', :regex=>'')
      @disaster = Cuisine.make(:name=>'Disaster', :regex=>'(incomlet')
    end
    
    should "match names appropriately" do
      assert_same_elements [@cafe, @pizzeria], Cuisine.matching_name("Bob's Pizzas and Coffee")
      assert_same_elements [@cafe], Cuisine.matching_name("The Imp Cafe")
      assert_same_elements [], Cuisine.matching_name("Eugene's Pasta")
    end
    
  end
  
end
