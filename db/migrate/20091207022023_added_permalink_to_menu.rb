class AddedPermalinkToMenu < ActiveRecord::Migration
  def self.up
    add_column :menus, :permalink, :string
  end

  def self.down
    remove_column :menus, :permalink
  end
end
