class AddedNameFieldsToClaim < ActiveRecord::Migration
  def self.up
    add_column :claims, :first_name, :string
    add_column :claims, :last_name, :string
  end

  def self.down
    remove_column :claims, :first_name
    remove_column :claims, :last_name
  end
end
