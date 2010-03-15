require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  
  context "For a given shop" do
    setup do
      @shop = Shop.make
      Shop.stubs(:find).with(any_parameters).returns(@shop)
    end

    context "posting a vote" do
      setup do
        post :create, :shop_id=>@shop.id
      end              
      
      before_should "create a vote for that shop" do
        votes = Object.new
        votes.expects(:create).once
        @shop.stubs(:votes).returns(votes)
      end
    end
  end
  
end
