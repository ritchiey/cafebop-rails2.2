class AddNameAndUserEmailToOrder < ActiveRecord::Migration
  
  def self.up
    add_column :orders, :name, :string
    add_column :orders, :user_email, :string
  end

  def self.down
    remove_column :orders, :name
    remove_column :orders, :user_email
  end

end
