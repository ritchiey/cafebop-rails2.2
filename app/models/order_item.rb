class OrderItem < ActiveRecord::Base
  STATES = %w(pending queued printed made delivered)

  fields do
    description :string
    quantity :integer
    price_in_cents    :integer
    notes    :string
    state    :string, :default => 'pending'
    timestamps
  end

  belongs_to :item_queue
  belongs_to :order
  belongs_to :menu_item
  belongs_to :size
  belongs_to :flavour

  before_create :set_values_from_menu_item

  treat_as_currency :price
  
  validates_presence_of :state
  validates_inclusion_of :state, :in => STATES
  validates_numericality_of :quantity, :greater_than => 0, :message => 'is minimum 1'
  validates_numericality_of :price_in_cents, :greater_than => 0#, :allow_nil => true

  


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
      self.state = 'printed'
      self.save
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
      self.save
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
