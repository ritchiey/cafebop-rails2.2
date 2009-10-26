class CreateShopCuisines < ActiveRecord::Migration
  def self.up
    create_table :shop_cuisines do |t|
      t.references :shop
      t.references :cuisine

      t.timestamps
    end
  end

  def self.down
    drop_table :shop_cuisines
  end
end
