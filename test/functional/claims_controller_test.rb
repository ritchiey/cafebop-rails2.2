require 'test_helper'

class ClaimsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  context "With a community shop" do
    setup do
      @shop = Shop.make
      @shop.transition_to('community')
      assert @shop.community?
    end
    
    context "with another claim against it" do
      setup do
        @other_user = User.make(:active)
        @other_claim = @shop.claims.make(:user=>@other_user)
        assert @other_claim.pending?
      end
                 
      context "when authenticated as an administrator" do
        setup do
          login_as_admin
        end
         
        should "be able to review a claim" do
          assert_difference "Claim.state_eq('under_review').count", 1 do
            put :review, :id=>@other_claim.id
          end
        end

      end

      context "which is under review" do
        setup do             
          @reviewer = make_admin
          @other_claim.review!(@reviewer)
          assert @other_claim.under_review?
        end

         context "when unauthenticated" do
           should "not be able to lodge a claim" do
             assert_no_difference "Claim.count" do                           
               @user= User.make(:active)
               post :create, :shop_id=>@shop.to_param, :claim=>{:user=>@user}
             end
           end                                 

           should "not be able to review a claim" do
             assert_no_difference "Claim.state_eq('under_review').count" do
               put :review, :id=>@other_claim.id
             end
           end
   
           should "not be able to confirm a claim" do
             assert_no_difference "Claim.state_eq('confirmed').count" do
               put :confirm, :id=>@other_claim.id
             end
           end

           should "not be able to reject a claim" do
             assert_no_difference "Claim.state_eq('rejected').count" do
               put :reject, :id=>@other_claim.id
             end
           end
   
           should "not be able to destroy a claim" do
             assert_no_difference "Claim.count" do
               delete :destroy, :id=>@other_claim.id
             end
           end
         end

         context "when authenticated as an active user" do
           setup do
             @user = User.make(:active)
             login_as @user
           end

           should "be able to lodge a claim" do
             assert_difference "Claim.count", 1 do                           
               @user= User.make(:active)
               post :create, :shop_id=>@shop.to_param, :claim=>{:user=>@user}
             end
           end                                 

           should "not be able to review a claim" do
             assert_no_difference "Claim.state_eq('under_review').count" do
               put :review, :id=>@other_claim.id
             end
           end
   
           should "not be able to confirm a claim" do
             assert_no_difference "Claim.state_eq('confirmed').count" do
               put :confirm, :id=>@other_claim.id
             end
           end

           should "not be able to reject a claim" do
             assert_no_difference "Claim.state_eq('rejected').count" do
               put :reject, :id=>@other_claim.id
             end
           end
   
           should "not be able to destroy a claim" do
             assert_no_difference "Claim.count" do
               delete :destroy, :id=>@other_claim.id
             end
           end


         end

         context "when authenticated as an administrator" do
           setup do
             login_as_admin
           end

           should "be able to lodge a claim" do
             assert_difference "Claim.count", 1 do                           
               @user= User.make(:active)
               post :create, :shop_id=>@shop.to_param, :claim=>{:user=>@user}
             end
           end                                 

           should "be able to confirm a claim" do
             assert_difference "Claim.state_eq('confirmed').count", 1 do
               put :confirm, :id=>@other_claim.id
             end
           end

           should "be able to reject a claim" do
             assert_difference "Claim.state_eq('rejected').count", 1 do
               put :reject, :id=>@other_claim.id
             end
           end
   
           should "be able to destroy a claim" do
             assert_difference "Claim.count", -1 do
               delete :destroy, :id=>@other_claim.id
             end
           end



       end
 


      end
      
 
    end
  end

  context "With an express shop" do
    setup do
      @shop = Shop.make
      @shop.transition_to('express')
      assert @shop.express?
    end
  end

  
end
