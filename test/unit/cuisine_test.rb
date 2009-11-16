require 'test_helper'

class CuisineTest < ActiveSupport::TestCase
  
  context "A couple of cuisines" do
    setup do
      @cuisine = Cuisine.make(:franchise=>false)
      @franchise = Cuisine.make(:franchise=>true)
    end
    
    should "appear in the correct searches" do
      assert_same_elements [@cuisine], Cuisine.is_not_franchise
      assert_same_elements [@franchise], Cuisine.is_franchise
    end
                              
  end
end
