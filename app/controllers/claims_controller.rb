class ClaimsController < ApplicationController    

  before_filter :require_login
  
  def create
    @shop = Shop.find(params[:shop_id])
    @claim = @shop.claims.build(:user=>current_user)
    if @claim and @claim.save
      flash[:notice] = "Your claim for #{@shop.name} has been registered. We'll be in touch."
    end
    redirect_to new_shop_order_path
  end          
  
  def index
    @pending_claims = Claim.pending
    @my_claims = current_user.claims_to_review
  end

  def review
    @claim = Claim.find(params[:id])
    @claim.review!(current_user)     
    @claim.save
    redirect_to @claim
  end                 
  
  def show
    @claim = Claim.find(params[:id])
  end                               
  
  def confirm
    @claim = Claim.find(params[:id])
    @claim.confirm!
    if @claim.save
      flash[:notice] = "Claim confirmed"
      redirect_to claims_path
    else
      render @claim
    end
  end
  
  def reject
    @claim = Claim.find(params[:id])
    @claim.reject!
    if @claim.save
      flash[:notice] = "Claim rejected"
      redirect_to claims_path
    else
      render @claim
    end
  end
  
end
