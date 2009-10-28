class Size < ActiveRecord::Base


  fields do
    name            :string
    description     :string
    price_in_cents  :integer
    extras_price    :string  
    position        :integer
    timestamps
  end

  has_many :order_items, :dependent=>:nullify
  belongs_to :menu_item

  validates_presence_of :name
  validates_numericality_of :price_in_cents, :greater_than => 0
  
  treat_as_currency :price
  acts_as_list :scope=>:menu_item

  def to_s
    "#{name} (#{price})"
  end
end
