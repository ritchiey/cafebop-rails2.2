class FriendshipsController < ApplicationController
  
  make_resourceful do
    actions :new, :destroy
    belongs_to :user  
    
    response_for :destroy do |format|
      format.html {redirect_to root_path}
    end                   
    
    # response_for :create do |format|
    #   format.html {redirect_to root_path}
    # end                   

  end
    
  def create
    @friendship = current_user.friendships.build(params[:friendship])
    @friendship.save
    redirect_to root_path
  end

end
