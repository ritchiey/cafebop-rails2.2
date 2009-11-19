class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships, :force => true do |t|
      t.integer :user_id
      t.integer :friend_id
    end
  end

  def self.down
    drop_table :friendships
  end
end
