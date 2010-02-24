require 'digest/sha1'


class Order < ActiveRecord::Base
  
  include OrderInvitation       
#  include PaypalEnabled
                        
  fields do
    notes :text
    state :string, :default=>'pending' 
    user_email :string
    name  :string
    perishable_token :string
    minutes_til_close :integer
    close_time :datetime
    paypal_paykey :string
    paid_at :datetime
    timestamps
  end

  before_create :init_perishable_token
  before_create :inherit_from_parent
  before_create :add_to_customer_queue
  before_save :start_close_timer
  before_save :set_user_from_user_email
  before_save :set_name_from_user
  after_save :confirm_if_child
  after_save :invite_additional_users
  
  belongs_to :user
  belongs_to :shop
  belongs_to :customer_queue
  has_many :order_items, :dependent=>:destroy
  has_many :payment_notifications, :dependent=>:destroy

  has_many :child_orders, :class_name=>'Order', :foreign_key=>'parent_id'
  has_many :child_order_items, :through=>:child_orders, :source=>'order_items'
  has_many :confirmed_child_order_items, :through => :child_orders, :source => :order_items, :conditions=>{"orders.state" => ['confirmed', 'made']}
  has_many :invited_users, :through => :child_orders, :source => :user
  belongs_to :parent, :class_name=>'Order'
  belongs_to :customer_queue
  
  named_scope :current, :conditions=>{:state=>%w/invited pending queued pending_paypal_auth/}
  named_scope :with_items, :joins=>:order_items
  named_scope :recent, :conditions=>["orders.created_at > ?", 4.hours.ago]
  named_scope :newest_first, :order=>"created_at DESC"    
      
  accepts_nested_attributes_for :order_items, :allow_destroy=>true
  
  attr_accessor :name_required

  
  validates_presence_of :effective_name, :if=>:name_required
  
  
  def effective_name
    self[:name] || (user && user.to_s)
  end
  
  def effective_name=(name)
    self[:name] = name
  end

  def can_be_queued?
    name and name.length > 0
  end

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

  def paid?
    paid_at
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
  
  def queued_order_items
    order_items.queued.all + child_order_items.queued.all
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
    all_confirmed_order_items.inject(0) {|sum, item| sum + item.cost}
  end
  
  def grand_total_with_fees
    grand_total + effective_processing_fee
  end
  
  def commission_rate
    shop.commission_rate
  end   

  def commission
    (grand_total * 100 * commission_rate).ceil / 100.0 
  end
                       
  def net_total
    grand_total - commission
  end
  
  def effective_processing_fee
    shop_pays_fee? ? 0 : shop.processing_fee
  end
  
  def paypal_recipient
    shop.paypal_recipient
  end      
  
  def shop_pays_fee?
    grand_total >= shop.fee_threshold.to_f    
  end
  
  def close_early!
    self.close_time = Time.now if waiting_for_close?
    self.save!
  end

  # Called by an order_item of this order when its state changes to made
  def order_item_made(order_item)
    if is_child?
      parent.order_item_made(order_item)
    else
      make! if all_confirmed_order_items_made?
    end
  end
  
  def parent_order_made
    make!
  end

  def summary
    summarized_order_items.map {|oi| "#{oi[:quantity]} #{oi[:description]}" }.join(', ')
  end
  
  def summarized_order_items
    OrderItem.summarize(all_confirmed_order_items.select {|o| o.queued? or o.made?})
  end                                  
  
  def all_confirmed_order_items
    order_items.all + confirmed_child_order_items.all
  end

  def payment_method
    if paid_at
      'PayPal'
    else
      'In shop'
    end
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
    (user_id and claimant.id == user_id) or token == perishable_token
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

  def pay_and_queue!
    if pending_paypal_auth?
      self.paid_at = Time.now
      queue!
    end
  end
      
  def cancel_paypal!
    if pending_paypal_auth?
      self.state = 'pending'
      save
    end
  end
      
  def confirm!
    if pending? && is_child? && parent.pending?
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
  
  def pay_paypal!
    if shop.accepts_paypal_payments?
      self.state = 'pending_paypal_auth'
      save
    else
      raise "Shop doesn't accept paypal payment"
    end
  end

  def make!
    if queued? or confirmed?
      self.state = 'made'
      save
      child_orders.each {|o| o.parent_order_made}
    end
  end

  def deliver!
    if made?
      self.state = 'delivered'
      save
    end
  end

  
  def confirm_if_child
    if pending? && is_child? && parent.pending? and !order_items.empty?
      self.state = 'confirmed'
      save!
    end
  end
  
  # End state related methods
  
private  

  def print_or_queue!
    if pending?
      if shop.queues_in_shop_payments?
        queue!
      else
        order_items.each {|item| item.print!}
        self.state = 'printed'
        save
      end
    end
  end  

  def queue!
    transaction do
      if can_be_queued?
        order_items.each {|item| item.queue!}
        confirmed_child_order_items.each {|item| item.queue!}
        self.state = 'queued'
        save
      end
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
  
  def all_confirmed_order_items_made?
    all_confirmed_order_items.all? {|item| item.made?}
  end
  
  def add_to_customer_queue
    is_child? or self.customer_queue = shop.customer_queues.first
  end


  def set_user_from_user_email
    if !self[:user_id] and user_email
      self.user = User.for_email(user_email)
    end
  end

  def set_name_from_user
    self.user and self.name ||= user.to_s
  end
  
end
