class CreateCuisineMenus < ActiveRecord::Migration
  def self.up
    create_table :cuisine_menus do |t|
      t.references :cuisine
      t.references :menu

      t.timestamps
    end
  end

  def self.down
    drop_table :cuisine_menus
  end
end
