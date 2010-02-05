class AddedEmailOffersFieldToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_offers, :boolean, :default=>true
  end

  def self.down
    remove_column :users, :email_offers
  end
end
