require 'test_helper'

class CuisineTest < ActiveSupport::TestCase
  should "be valid" do
    assert Cuisine.new.valid?
  end
end
