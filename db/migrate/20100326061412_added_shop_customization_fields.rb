class AddedShopCustomizationFields < ActiveRecord::Migration
  def self.up
    add_column :shops, :display_name, :boolean, :default => true
    add_column :shops, :tile_border, :boolean, :default => true
    add_column :shops, :border_background_updated_at, :datetime
    add_column :shops, :border_background_file_name, :string
    add_column :shops, :border_background_content_type, :string
    add_column :shops, :border_background_file_size, :integer
  end

  def self.down
    remove_column :shops, :display_name
    remove_column :shops, :tile_border
    remove_column :shops, :border_background_updated_at
    remove_column :shops, :border_background_file_name
    remove_column :shops, :border_background_content_type
    remove_column :shops, :border_background_file_size
  end
end
