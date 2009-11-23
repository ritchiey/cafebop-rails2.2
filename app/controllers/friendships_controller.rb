class FriendshipsController < ApplicationController
  
  make_resourceful do
    actions :new, :create, :destroy
    belongs_to :user  
    
    response_for :create, :destroy do |format|
      format.html {redirect_to root_path}
    end                   
    
  end

end
