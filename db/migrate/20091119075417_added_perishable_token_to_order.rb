class AddedPerishableTokenToOrder < ActiveRecord::Migration
  def self.up
    add_column :friendships, :created_at, :datetime
    add_column :friendships, :updated_at, :datetime
    
    add_column :orders, :perishable_token, :string
  end

  def self.down
    remove_column :friendships, :created_at
    remove_column :friendships, :updated_at
    
    remove_column :orders, :perishable_token
  end
end
