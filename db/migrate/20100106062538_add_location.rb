class AddLocation < ActiveRecord::Migration
  def self.up
    add_column :shops, :location_accuracy, :integer
  end

  def self.down
    remove_column :shops, :location_accuracy
  end
end
