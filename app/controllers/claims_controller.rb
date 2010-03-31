class ClaimsController < ApplicationController

  before_filter :require_login_for_claim
  before_filter :require_can_review_claims, :except=>[:new, :create]
  before_filter :find_claim, :except => [:new, :create, :index]
  
  def new
    @claim = @shop.claims.build(:user=>current_user)
  end
  
  def create
    @claim = @shop.claims.build(params[:claim].merge(:user=>current_user))
    if @claim and @claim.save
      flash[:notice] = "Your claim for #{@shop.name} has been registered. We'll be in touch."
    end
    redirect_to new_shop_order_path(@shop)
  end          
  
  def index
    @pending_claims = Claim.pending
    @my_claims = current_user.claims_to_review
  end

  def review
    @claim.review!(current_user)     
    @claim.save
    redirect_to claim_path(@claim)
  end                 
  
  def show     
    @user = @claim.user :include=>[:claims]
    @confirmed_claims = @user.claims.select {|c| c.confirmed?}.size
    @outstanding_claims = @user.claims.select {|c| c.outstanding?}.size
    @rejected_claims = @user.claims.select {|c| c.rejected?}.size
  end                               
  
  def confirm
    @claim.confirm! and flash[:notice] = "Claim confirmed"
    redirect_to claims_path
  end
  
  def reject
    @claim.reject!
    if @claim.save
      flash[:notice] = "Claim rejected"
      redirect_to claims_path
    else
      render @claim
    end
  end          
  
  def destroy
    @claim.destroy
    flash[:notice] = "Successfully destroyed claim."
    redirect_to claims_path
  end

private

  def require_login_for_claim
    require_login "Please login or register to lodge a claim."
  end 
  
  def find_claim
    @claim = Claim.find(params[:id])
  end
  
end
