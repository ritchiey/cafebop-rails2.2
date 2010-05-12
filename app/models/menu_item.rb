class MenuItem < ActiveRecord::Base

  fields do
    name  :string
    description :string
    price_in_cents :integer
    position :integer
    present_flavours :boolean, :default=>false
    timestamps
  end

  validates_length_of :name, :minimum => 1
  validates_numericality_of :price_in_cents, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_presence_of :price, :on => :create, :message => "must be specified"
                        
  has_many :flavours, :dependent=>:destroy, :order=>:position 
  has_many :sizes, :dependent=>:destroy, :order=>:position
  has_many :order_items, :dependent=>:nullify
  
  belongs_to :item_queue
  belongs_to :menu

  # This specifies the menu containing extras suitable to add to this menu item
  belongs_to :extras_menu, :class_name=>"Menu"
  
  treat_as_currency :price #create virtual price attribute
  accepts_nested_attributes_for :flavours, :allow_destroy=>true, :reject_if=>lambda {|f| f[:name].blank?} 
  accepts_nested_attributes_for :sizes, :allow_destroy=>true, :reject_if=>lambda {|s| s[:name].blank?} 
  acts_as_list :scope=>:menu
    

  # Accept sizes in price field in the format size:price
  alias_method :normal_price=, :price=
  def price=(value)
    price_attributes = parse_prices(value)
    if price_attributes
      self.sizes = price_attributes.map do |attrs|
        (size = sizes.find_by_name(attrs['name']) || Size.new).attributes = attrs
        size
      end
    else
      self.normal_price=value
    end
  end

  # alias_method :normal_price, :price
  # def price                         
  #   if sizes.empty?
  #     normal_price
  #   else
  #     sizes.map {|s| "#{s.name}:$#{s.price}"}.join(', ')
  #   end
  # end
  
  before_create :set_default_queue
  
  def to_s
    name
  end

  def shop
    menu.andand.shop
  end


  def ordering_json
    OrderItem.new({:menu_item=>self}).to_json(
      :include=>{:menu_item=>{:include=>[:sizes,:flavours], :only=>[:name, :price_in_cents, :id, :item_queue_id]}},
      :only=>[:description]
    )
  end

  def deep_clone
    self.clone.tap do |cloned|
      cloned.save!
      cloned.flavours = flavours.map {|flavour| flavour.clone.tap {|o| o.save!}}
      cloned.sizes = sizes.map {|size| size.clone.tap {|o| o.save!}}
    end
  end
  
  def managed_by? user
    menu && menu.managed_by?(user)
  end

private

  def set_default_queue      
    unless has_item_queue? or !shop or !shop.has_item_queues? 
      self.item_queue = shop.item_queues.first
    end
  end

  def has_item_queue?
    self[:item_queue_id]
  end


  def parse_prices(str)
    attrs = []
    i=0
    while str =~ /^[, ]*(.+?):\$?([0-9.]+)/o
      attrs << {:name=>$1, :price=>$2, :position=>(i += 1)}
      str = $'
    end
    attrs.empty? ? nil : attrs
  end                                 


end
