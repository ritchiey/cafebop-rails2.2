class AddedPositionFieldToSizesAndFlavours < ActiveRecord::Migration
  def self.up
    add_column :sizes, :position, :integer
    
    add_column :flavours, :position, :integer
  end

  def self.down
    remove_column :sizes, :position
    
    remove_column :flavours, :position
  end
end
