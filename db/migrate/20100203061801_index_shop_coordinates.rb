class IndexShopCoordinates < ActiveRecord::Migration
  def self.up
    add_index "shops", ["lat"], :name => "index_shops_on_lat"
    add_index "shops", ["lng"], :name => "index_shops_on_lng"
  end

  def self.down
    remove_index :shops, :column => [:lat]
    remove_index :shops, :column => [:lng]
  end
end
