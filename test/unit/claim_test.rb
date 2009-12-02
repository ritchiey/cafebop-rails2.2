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
    
    should "send and email and not be under_review after rejection" do
      @claim.reject!
      @reject_email = ActionMailer::Base.deliveries.last
      assert_match /Unfortunately, your claim for #{@claim.shop} was unsuccessful/, @reject_email.body
      assert !@claim.under_review?
      assert !@reviewer.claims_to_review.include?(@claim)
    end                 
    
    should "call claim! on associated shop, send an email and create a work_contract record when confirmed" do
      assert @shop.community?
      @claim.confirm!
      @confirm_email = ActionMailer::Base.deliveries.last
      assert_match /We are very pleased to inform you that your claim for #{@claim.shop} was successful/, @confirm_email.body
      assert @shop.express?
      assert @shop.managers.include? @claim.user
    end
  end
  
end