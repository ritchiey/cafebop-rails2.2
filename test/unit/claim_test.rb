require File.dirname(__FILE__) + '/../test_helper'

class ClaimTest < ActiveSupport::TestCase
  
  context "a claim" do
    
    setup do  
      @claim = Claim.make
      @user = User.make
    end
    
    should "default to pending" do
      assert @claim.pending?
      assert Claim.pending.include?(@claim)
    end

    should "not be pending after review!" do
      assert @claim.pending?
      assert Claim.pending.include?(@claim)
      assert !@user.claims_to_review.include?(@claim)
      @claim.review!(@user)
      assert !@claim.pending?
      assert !Claim.pending.include?(@claim)
      assert @user.claims_to_review.include?(@claim)
    end
    

  end
      
  context "a claim under review" do

    setup do  
      @reviewer = User.make
      @claim = Claim.make
      @shop = @claim.shop
      @claim.review!(@reviewer)
      assert @claim.under_review?
      assert @reviewer.claims_to_review.include?(@claim)
    end
    
    should "not be under_review after rejection" do
      @claim.reject!
      assert !@claim.under_review?
      assert !@reviewer.claims_to_review.include?(@claim)
    end                 
    
    should "call claim! on associated shop and create a work_contract record when confirmed" do
      assert @shop.community?
      @claim.confirm!
      assert @shop.express?
      assert @shop.managers.include? @claim.user
    end
  end
  
end