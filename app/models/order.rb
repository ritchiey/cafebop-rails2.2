require 'digest/sha1'


class Order < ActiveRecord::Base
  
  include OrderInvitation       
  include PaypalEnabled
                        
  #TODO: Add field to differentiate paid confirmed orders from unpaid confirmed
  fields do
    notes :text    
    state :string, :default=>'pending'
    perishable_token :string
    minutes_til_close :integer
    close_time :datetime
    paid_at :datetime
    timestamps
  end

  
  before_create :init_perishable_token
  before_create :inherit_from_parent
  before_save :start_close_timer
  before_save :set_user_from_user_email
  after_save :invite_additional_users
  
  belongs_to :user
  belongs_to :shop
  has_many :order_items, :dependent=>:destroy

  has_many :child_orders, :class_name=>'Order', :foreign_key=>'parent_id'
  has_many :child_order_items, :through=>:child_orders, :source=>'order_items'
  has_many :invited_users, :through => :child_orders, :source => :user
  belongs_to :parent, :class_name=>'Order'
  
  named_scope :current, :conditions=>{:state=>%w/invited pending queued pending_paypal_auth/}
  named_scope :with_items, :joins=>:order_items
  named_scope :recent, :conditions=>["orders.created_at > ?", 4.hours.ago]
  named_scope :newest_first, :order=>"created_at DESC"    
      
  accepts_nested_attributes_for :order_items, :allow_destroy=>true
  
  # Parent order invitation closed
  def invite_closed?
    (invited? or pending?) and parent and !parent.pending?
  end
        
  def set_user user
    unless self.user
      self.user = user
      save
    end
  end
                
  def is_child?
    parent
  end                 
  
  def is_parent?
    !self.child_orders.empty?
  end
  
  def is_in_group?
    is_child? or is_parent?
  end             
  
  def group
    is_child? ? parent : self
  end                      
  
  def can_confirm?
    return false unless pending?
    return true if is_child?
    !waiting_for_close?
  end
  
  def originator
    (is_child? ? parent.user : self.user) || "unknown"
  end

  def invite invitee
      child_orders.create(:user=>invitee) unless is_child?
  end

  def total
    order_items.inject(0) {|sum, item| sum + item.cost}
  end
  
  def grand_total
    total +
    child_order_items.inject(0) {|sum, item| sum + item.cost}
  end
  
  def commission_rate
    0.01
  end   

  def commission
    (total * 100 * commission_rate).ceil / 100.0 
  end
                       
  def net_total
    total - commission
  end
  
  def close_early!
    self.close_time = Time.now if waiting_for_close?
    self.save!
  end

  # Called by an order_item of this order when its state changes to made
  def order_item_made(order_item)
    make! if order_items.all? {|item| item.made?}
  end

  # State related methods
  def pending?() state == 'pending'; end  
  def invited?()   state == 'invited'; end  
  def declined?()   state == 'declined'; end  
  def confirmed?()  state == 'confirmed'; end
  def pending_paypal_auth?() state == 'pending_paypal_auth'; end  
  def printed?()   state == 'printed'; end  
  def queued?()   state == 'queued'; end  
  def made?()   state == 'made'; end  
  def cancelled?()   state == 'cancelled'; end  
  def reported?()   state == 'reported'; end
              

  def self.invite!(params={})
    self.new(params).tap do |order|
      order.save!
    end
  end
  
  
  def mine? claimant, token
    (user and claimant == user) or token == perishable_token
  end
  
  
  def accept!
    if invited?
      self.state = 'pending'
      save!
    end
  end  
  
  def decline!
    if invited?
      self.state = 'declined'
      save!
    end
  end

  def confirm_paid!
    if pending_paypal_auth?
      self.paid_at = Time.now
      self.state = 'confirmed'
      save!
    end
  end
      
  def confirm!
    if pending? && is_child?
      self.state = 'confirmed'
      save!
    end
  end
  
  def pay_in_shop! 
    if shop.accepts_in_shop_payments?
      print_or_queue!
    else
      raise "Shop doesn't accept in-shop payment"
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

  def print_or_queue!
    if pending?
      if shop.queues_in_shop_payments?
        order_items.each {|item| item.queue!}
        OrderItem.order_parent_id_eq(self.id).order_state_eq('confirmed').all(:readonly=>false).each do |item|
          item.queue!
        end
        self.state = 'queued'   
      else
        order_items.each {|item| item.print!}
        self.state = 'printed'
      end
      save
    end
  end  
  
  def should_start_close_timer?
    @start_close_timer == 'true'
  end

  def invite_additional_users
    if should_start_close_timer? and !is_child? and self[:user_id]
      invitees = User.for_emails(invited_user_attributes)
      (invitees - invited_users.all).each {|user| invite user}
    end
  end

  def start_close_timer
    if should_start_close_timer? and !close_timer_started?
      self[:close_time] = minutes_til_close.to_i.minutes.from_now
      inviting = false
    end
    true
  end
  
  def inherit_from_parent
    if is_child?
      self.state = 'invited'   
      self.shop = parent.shop
    end
  end  
  
  def init_perishable_token
    self.perishable_token = Digest::SHA1.hexdigest("Wibble!#{rand.to_s}")
  end
  
end
