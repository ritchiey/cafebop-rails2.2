class AddedMinutesTilClose < ActiveRecord::Migration
  def self.up
    add_column :orders, :minutes_til_close, :integer
  end

  def self.down
    remove_column :orders, :minutes_til_close
  end
end
