class Size < ActiveRecord::Base


  fields do
    name         :string
    description  :string
    price        :integer
    extras_price :string
    timestamps
  end

  has_many :order_items, :dependent=>:nullify

  belongs_to :menu_item

  validates_length_of :name, :minimum=>1

end
