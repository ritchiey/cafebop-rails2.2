class CustomerQueue < ActiveRecord::Base    
  
  fields do
    name :string, :default=>'Front counter'
    active  :boolean, :default=>false
    position :integer
    timestamps
  end
  
  belongs_to :shop
  has_many :orders
  has_many :current_orders,
          :class_name=>'Order',
          :foreign_key=>'customer_queue_id',
          :order=>"created_at ASC",
          :conditions=>{:state =>'queued'},
          :include=>[:order_items]

  attr_accessible :name, :active

end
