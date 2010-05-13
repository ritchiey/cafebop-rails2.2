class ShopDeliveryAndMenuDescription < ActiveRecord::Migration
  def self.up
    add_column :menus, :description, :string
    
    add_column :shops, :deliver, :boolean
    add_column :shops, :delivery_area, :string
  end

  def self.down
    remove_column :menus, :description
    
    remove_column :shops, :deliver
    remove_column :shops, :delivery_area
  end
end
