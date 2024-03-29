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
  
  has_one :user, :through=>:order
  has_one :shop, :through=>:order
  
  attr_accessible :quantity, :notes, :menu_item, :size, :flavour,
                  :menu_item_id, :size_id, :flavour_id

  before_validation_on_create :set_values_from_menu_item
  before_create :only_if_order_pending  
  
  named_scope :queued, :conditions=>{:state=>'queued'}

  treat_as_currency :price
  
  validates_presence_of :state
  validates_presence_of :menu_item, :on => :create
  validates_inclusion_of :state, :in => STATES
  validates_numericality_of :quantity, :greater_than => 0
  validates_numericality_of :price_in_cents, :greater_than => 0#, :allow_nil => true
  
  
  # Given a list of order items, compress duplicates into
  # individual line items
  def self.summarize(items)
    {}.tap do |map|
      items.each do |item|
        key = {
          :description => item.description,
          :notes => item.notes,
          :price_in_cents=>item.price_in_cents,
          :state=>item.state
        }
        map[key] ||= {:quantity=>0, :ids=>[]}
        map[key][:ids].push(item.id)
        map[key][:quantity] += item.quantity
      end
    end.to_a.map do |pair|
      (key, body) = *pair
      key.merge(body)
    end
  end

  # def shop() order.shop; end
  # def user() order.user; end

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

  def only_if_order_pending
    order.pending?
  end

  def set_values_from_menu_item
    self[:item_queue_id] = menu_item.item_queue_id
    self.price_in_cents = size ? size.price_in_cents : menu_item.price_in_cents
    self.description = calc_description
    true
  end

  def calc_description
    (size ? "#{size.name} ":'') +
      (flavour ? "#{flavour.name} ":'') +
      menu_item.name
  end


end
