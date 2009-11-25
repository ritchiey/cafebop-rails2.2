class FriendshipsController < ApplicationController
  
  make_resourceful do
    actions :new, :create, :destroy
    belongs_to :user  
    
    response_for :destroy do |format|
      format.html {redirect_to root_path}
    end                   
    
    response_for :create do |format|
      format.html {redirect_to root_path}
    end                   
    
  end

end
