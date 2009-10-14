class Order < ActiveRecord::Base
      
  fields do
    notes :text    
    state :string, :default=>'pending'
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

  def total
    order_items.inject(0) {|sum, item| sum + item.cost}
  end
    
  # Called by an order_item of this order when its state changes to made
  def order_item_made(order_item)
    make! if order_items.all? {|item| item.made?}
  end

  # State related methods
  def pending?() state == 'pending'; end  
  def invited?()   state == 'invited'; end  
  def declined?()   state == 'declined'; end
  def pending_paypal_auth?() state == 'pending_paypal_auth'; end  
  def printed?()   state == 'printed'; end  
  def queued?()   state == 'queued'; end  
  def made?()   state == 'made'; end  
  def cancelled?()   state == 'cancelled'; end  
  def reported?()   state == 'reported'; end

  def pay_in_shop! 
    if shop.accepts_in_shop_payments?
      confirm!
    else
      throw Exception.new "Shop doesn't accept in-shop payment"
    end
  end

  def request_paypal_authorization!
    if pending?
      # TODO: request paypal authorization
      self.state = 'pending_paypal_auth'
    end
  end

  def make!
    if queued?
      self.state = 'made'  
      save
    end
  end
  # End state related methods
private

  def confirm!
    if pending?
      if shop.queues_in_shop_payments?
        order_items.each {|item| item.queue!}
        self.state = 'queued'   
        save
      else
        order_items.each {|item| item.print!}
        self.state = 'printed'
        save
      end
    end
  end

end
