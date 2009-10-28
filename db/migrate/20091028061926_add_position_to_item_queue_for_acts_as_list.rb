class AddPositionToItemQueueForActsAsList < ActiveRecord::Migration
  def self.up
    add_column :item_queues, :position, :integer
  end

  def self.down
    remove_column :item_queues, :position
  end
end
