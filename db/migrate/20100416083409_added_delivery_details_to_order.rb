class AddedDeliveryDetailsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :phone, :string
    add_column :orders, :deliver, :boolean
    add_column :orders, :address, :string
    add_column :orders, :queue_after, :datetime
    
    add_column :users, :address, :string
  end

  def self.down
    remove_column :orders, :phone
    remove_column :orders, :deliver
    remove_column :orders, :address
    remove_column :orders, :queue_after
    
    remove_column :users, :address
  end
end
