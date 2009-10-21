class AddedLatitudeAndLongitudeToSuburb < ActiveRecord::Migration
  def self.up
    add_column :suburbs, :lng, :float
    add_column :suburbs, :lat, :float
  end

  def self.down
    remove_column :suburbs, :lng
    remove_column :suburbs, :lat
  end
end
