class AddedQueuedOrderTimestamps < ActiveRecord::Migration
  def self.up
    add_column :orders, :queued_at, :datetime
    add_column :orders, :unqueued_at, :datetime
  end

  def self.down
    remove_column :orders, :queued_at
    remove_column :orders, :unqueued_at
  end
end
