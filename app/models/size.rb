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

  validates_length_of :name, :minimum=>1

  treat_as_currency :price

  def to_s
    "#{name} (#{price})"
  end
end
