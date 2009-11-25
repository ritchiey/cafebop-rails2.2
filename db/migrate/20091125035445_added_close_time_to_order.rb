class AddedCloseTimeToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :close_time, :datetime
  end

  def self.down
    remove_column :orders, :close_time
  end
end
