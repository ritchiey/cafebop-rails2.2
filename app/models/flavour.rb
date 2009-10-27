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
  # --- Permissions --- #

  def create_permitted?
    return false unless menu_item
    menu_item && menu_item.creatable_by?(acting_user)
  end

  def update_permitted?
    return false if menu_item_changed?
    menu_item && menu_item.updatable_by?(acting_user)
  end

  def destroy_permitted?
    menu_item && menu_item.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    menu_item && menu_item.viewable_by?(acting_user, field)
  end

end
