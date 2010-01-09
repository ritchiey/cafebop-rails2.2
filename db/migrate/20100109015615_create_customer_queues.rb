class CreateCustomerQueues < ActiveRecord::Migration
  def self.up
    create_table :customer_queues do |t|
      t.string   :name, :default => "Front counter"
      t.boolean  :active, :default => false
      t.integer  :position
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
    end
    
    add_column :orders, :customer_queue_id, :integer
    
    change_column :shops, :fee_threshold_in_cents, :integer, :default => 0
  end

  def self.down
    remove_column :orders, :customer_queue_id
    
    change_column :shops, :fee_threshold_in_cents, :integer, :default => 1500
    
    drop_table :customer_queues
  end
end
