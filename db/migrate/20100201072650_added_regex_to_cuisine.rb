class AddedRegexToCuisine < ActiveRecord::Migration
  def self.up
    add_column :cuisines, :regex, :string
  end

  def self.down
    remove_column :cuisines, :regex
  end
end
