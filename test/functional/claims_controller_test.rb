require 'test_helper'

class ClaimsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  context "with a claimable shop" do
    setup do
      claims = mock
      @shop = mock("shop") do
        stubs(:name).returns("My Shop")
        stubs(:to_param).returns(12)
        stubs(:claims).returns(claims)  
        stubs(:can_be_claimed_by?).returns(true)
      end
      Shop.stubs(:find_by_id_or_permalink).returns(@shop)  
    end
  
    context "Given an existing claim" do
      setup do
        @existing_claim = mock('existing claim') do
          stubs(:to_param).returns("16")
        end
        Claim.stubs(:find).returns(@existing_claim)
      end
               
      context "when authenticated as a claims reviewer" do
        setup do
          controller.stubs(:current_user).returns(mock(:can_review_claims? => true))
        end
       
        context "reviewing the claim" do
          setup do
            @existing_claim.expects(:review!)#.with(@admin)
            @existing_claim.expects(:save).returns(true)
            put :review, :id=>@existing_claim.to_param
          end
          before_should "call review! on model" do

          end
          should_redirect_to("claim") {claim_path(@existing_claim)}
        end
      end

      context "which is under review" do
        setup do             
          @existing_claim.stubs(:under_review?).returns(true)
        end

         context "when unauthenticated" do
           setup do
            controller.stubs(:current_user).returns(nil)
           end

           context "lodging a claim" do
             setup do
               post :create, :shop_id=>@shop.to_param, :claim=>{:user=>@user}
             end
             should_require_login
           end
         
           context "attempting to review it" do
             setup do
               put :review, :id=>@existing_claim.to_param
             end
             should_require_login
           end
         
          
           context "attempting to confirm a claim" do
             setup do
               put :confirm, :id=>@existing_claim.to_param
             end
             should_require_login
           end
          
           context "attempting to reject a claim" do
             setup do
               put :reject, :id=>@existing_claim.to_param
             end
             should_require_login
           end
         
           context "attempting to destroy a claim" do
             setup do
               delete :destroy, :id=>@existing_claim.to_param
             end
             should_require_login
           end  
         end

         context "when authenticated as an active user" do
           setup do
             @user = User.make_unsaved(:active)
             controller.stubs(:current_user).returns(@user)
           end
         
           context "lodging a claim" do
             setup do
               @shop.claims.expects(:build).returns(mock(:save=>true))
               post :create, :shop_id=>@shop.to_param, :claim=>{:first_name=>'Tom', :last_name=>'Riddle', :agreement=>'i agree'}
             end         
             should_redirect_to("ordering screen for shop") {new_shop_order_path(@shop)}
           end
         
           context "reviewing a claim" do
             setup do
               put :review, :id=>@existing_claim.to_param
             end
             should_not_be_allowed
           end
            
           context "confirming a claim" do
             setup do
               put :confirm, :id=>@existing_claim.to_param
             end
             should_not_be_allowed
           end
           
           context "rejecting a claim" do
             setup do
               put :reject, :id=>@existing_claim.to_param
             end
             should_not_be_allowed
           end
           
           context "destroying a claim" do
             setup do
               delete :destroy, :id=>@existing_claim.to_param
             end
             should_not_be_allowed
           end
           
         end

         context "when authenticated as a claims reviewer" do
           setup do
             controller.stubs(:current_user).returns(mock(:can_review_claims? => true))
           end
           
           context "confirming a claim" do
             setup do
               @existing_claim.expects(:confirm!)
               put :confirm, :id=>@existing_claim.to_param
             end
             should_redirect_to("list of claims") {claims_path}
           end
           
           
           context "rejecting a claim" do
             setup do
               @existing_claim.expects(:reject!)
               @existing_claim.expects(:save).returns(true)
               put :reject, :id=>@existing_claim.to_param
             end
             should_redirect_to("claims path") { claims_path }
           end
          
           context "destroying the claim" do
             setup do
               @existing_claim.expects(:destroy).returns(true)
               delete :destroy, :id=>@existing_claim.to_param
             end
             should_redirect_to("claims path") { claims_path }
           end
         
         end
       end
     end 

  end

 end
