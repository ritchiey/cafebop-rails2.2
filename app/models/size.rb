class Size < ActiveRecord::Base


  fields do
    name            :string
    description     :string
    price_in_cents  :integer
    extras_price    :string  
    position        :integer
    timestamps
  end

# This looks like a bad thing. If the price record is deleted, we actually want
# to keep the order item.
#  has_many :order_items, :dependent=>:nullify
  belongs_to :menu_item

  validates_presence_of :name
  validates_numericality_of :price_in_cents, :greater_than => 0
  
  treat_as_currency :price
  acts_as_list :scope=>:menu_item
  
  def managed_by? user
    menu_item && menu_item.managed_by?(user)
  end

  def to_s
    "#{name} (#{price})"
  end
end
