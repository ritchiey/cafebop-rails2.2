class AddedUrlForFranchises < ActiveRecord::Migration
  def self.up
    add_column :cuisines, :url, :string
  end

  def self.down
    remove_column :cuisines, :url
  end
end
