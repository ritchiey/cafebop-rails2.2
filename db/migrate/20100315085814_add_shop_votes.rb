class AddShopVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.string   :email
      t.boolean  :notification_requested
      t.boolean  :confirmed
      t.string   :confirmation_key
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
      t.integer  :user_id
    end
    
    add_column :shops, :votes_count, :integer, :default => 0
  end

  def self.down
    remove_column :shops, :votes_count
    
    drop_table :votes
  end
end
