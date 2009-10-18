class OrderItem < ActiveRecord::Base

  fields do
    description :string
    quantity :integer
    price_in_cents    :integer   
    notes    :string    
    state    :string, :default=>'pending'
    timestamps
  end

  belongs_to :item_queue
  belongs_to :order
  belongs_to :menu_item
  belongs_to :size
  belongs_to :flavour
                          
  before_create :set_values_from_menu_item
  validates_numericality_of :quantity, :greater_than => 0, :message => 'minimum is 1'
                  
  treat_as_currency :price
 
  def user() order.user; end
  
  def cost_in_cents
    (quantity||0) * (price_in_cents||0)
  end
  
  def cost
    cost_in_cents / 100.0
  end
  
  def to_s
    description || calc_description
  end

  # State related    
  def pending?() state == 'pending'; end  
  def queued?()   state == 'queued'; end
  def printed?()  state == 'printed'; end
  def made?()   state == 'made'; end
  def delivered?() state = 'delivered'; end
  
  def queue!             
    if pending?
      self.state = 'queued'
      self.save
    end
  end
    
  def print!
    if pending?
      self.save
      self.state = 'printed'
    end
  end

  def make!
    if queued?
      self.state = 'made'
      if save
        order.order_item_made(self)
      end
    end
  end

  def deliver!
    if made?
      self.state = 'delivered'
      self.save!
    end
  end
  # End State related
  
private

  def set_values_from_menu_item
    self[:item_queue_id] = menu_item.item_queue_id
    self.price = size ? size.price : menu_item.price
    self.description = calc_description
  end  
  
  def calc_description
    (size ? "#{size.name} ":'') +
      (flavour ? "#{flavour.name} ":'') +
      menu_item.name
  end
  
end
