class AddedPositionToOperatingTime < ActiveRecord::Migration
  def self.up
    add_column :operating_times, :position, :integer
  end

  def self.down
    remove_column :operating_times, :position
  end
end
