class Order < ActiveRecord::Base
      
  fields do
    notes :text    
    state :string
    timestamps
  end
                 
  before_create :default_to_pending

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

  def total
    order_items.inject(0) {|sum, item| sum + item.cost}
  end

  # State related methods
  def pending?() state == 'pending'; end  
  def invited?()   state == 'invited'; end  
  def declined?()   state == 'declined'; end  
  def confirmed?()   state == 'confirmed'; end  
  def made?()   state == 'made'; end  
  def cancelled?()   state == 'cancelled'; end  
  def reported?()   state == 'reported'; end  

  def confirm!
    self.state = 'confirmed' if pending?
  end

  # End state related methods
private

  def default_to_pending
    self[:state] ||= 'pending'
  end
end
