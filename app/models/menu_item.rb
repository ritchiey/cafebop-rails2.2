class MenuItem < ActiveRecord::Base

  

  fields do
    name  :string  
    description :string
    price_in_cents :integer
    position :integer
    present_flavours :boolean, :default=>false
    timestamps
  end

  validates_length_of :name, :minimum=>1
                        
  has_many :flavours, :dependent=>:destroy
  has_many :sizes, :dependent=>:destroy, :order=>:position
  has_many :order_items, :dependent=>:nullify
  
  belongs_to :item_queue
  belongs_to :menu

  # This specifies the menu containing extras suitable to add to this menu item
  belongs_to :extras_menu, :class_name=>"Menu"
  
  treat_as_currency :price #create virtual price attribute

  accepts_nested_attributes_for :flavours, :sizes
  


  def shop
    menu.shop
  end


  def ordering_json
    OrderItem.new({:menu_item=>self}).to_json(
      :include=>{:menu_item=>{:include=>[:sizes,:flavours], :only=>[:name, :price_in_cents, :id, :item_queue_id]}},
      :only=>[:description]
    )
  end

end
