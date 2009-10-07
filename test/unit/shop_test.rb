require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase

  context "a shop" do
    
    setup do
      @shop = Shop.make
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
      
  end

end