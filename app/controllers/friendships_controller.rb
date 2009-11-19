class FriendshipsController < ApplicationController
  make_resourceful do
    actions :new, :create, :destroy, :index
    belongs_to :user
  end

end
