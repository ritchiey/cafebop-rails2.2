class VotesController < ApplicationController
  
  def create
    @shop = Shop.find(params[:shop_id])
    if @shop
      @vote = @shop.votes.create#(:user=>current_user) 
    end
    respond_to do |format|
      format.html {redirect_to root_path}
      format.json {render :json=>@vote.to_json(:include=>{:shop=>{:methods=>[:ranking]}})}
    end
  end
  
end
