class Order < ActiveRecord::Base
      
  fields do
    notes :text
    timestamps
  end

  belongs_to :user
  belongs_to :shop
  has_many :order_items, :dependent=>:destroy

  has_many :child_orders, :class_name=>'Order', :foreign_key=>'parent_id'
  has_many :child_order_items, :through=>:child_orders, :source=>'order_items'
  belongs_to :parent, :class_name=>'Order'

  def order_item_attributes=(order_items_attributes)
    order_items_attributes.each do |attr|
      order_items.build(attr)
    end
  end

end
