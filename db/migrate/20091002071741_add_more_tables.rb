class AddMoreTables < ActiveRecord::Migration
  def self.up    
    create_table :claims, :force => true do |t|
    end
  end

  def self.down
    drop_table :claims
  end
end
