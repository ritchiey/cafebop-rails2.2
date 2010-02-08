class Flavour < ActiveRecord::Base

  fields do
    name        :string
    description :string
    position    :integer
    timestamps
  end

  has_many :order_items, :dependent=>:nullify
  belongs_to :menu_item
  validates_presence_of :name

  acts_as_list :scope=>:menu_item


  def to_s
    name
  end   
  
  def ordering_json
    OrderItem.new({:menu_item=>menu_item, :flavour=>self}).to_json(
      :include=>{:menu_item=>{:include=>[:sizes], :only=>[:name, :price_in_cents, :id, :item_queue_id]},
        :flavour=>{:only=>[:name, :price_in_cents, :id]}
      },
      :only=>[:description]
    )
  end

  def display_price
    menu_item.display_price
  end

  def managed_by? user
    menu_item && menu_item.managed_by?(user)
  end
  

end
