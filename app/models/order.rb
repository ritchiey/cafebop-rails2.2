require 'digest/sha1'

class Order < ActiveRecord::Base
        
  fields do
    notes :text    
    state :string, :default=>'pending'
    perishable_token :string
    close_time :datetime
    timestamps
  end

  before_create :inherit_from_parent
  before_save :start_close_timer
  after_save :invite_additional_users
  
  belongs_to :user
  belongs_to :shop
  has_many :order_items, :dependent=>:destroy

  has_many :child_orders, :class_name=>'Order', :foreign_key=>'parent_id'
  has_many :invited_users, :through => :child_orders, :source => :user
  has_many :child_order_items, :through=>:child_orders, :source=>'order_items'
  belongs_to :parent, :class_name=>'Order'
  
  named_scope :current, :conditions=>{:state=>%w/invited pending queued pending_paypal_auth/}
  named_scope :with_items, :joins=>:order_items
  named_scope :recent, :conditions=>["orders.created_at > ?", 4.hours.ago]
  named_scope :newest_first, :order=>"created_at DESC"

  def minutes_til_close=(period)
    @minutes_til_close = period
  end
  
  def minutes_til_close
    @minutes_til_close || 10
  end
  
  def close_time
    is_child? ? parent.close_time : self[:close_time]
  end
  
  def closed?
    Time.now >= close_time
  end
  
  def waiting_for_close?
    close_timer_started? and !closed?
  end     
  
  def close_timer_started?
    close_time
  end
    
  accepts_nested_attributes_for :order_items, :allow_destroy=>true
  
  # These are the emails of the users that are to be invited when
  # the user is saved. Those not already invited (ie in invited_users)
  # will be invited
  def invited_user_attributes=(emails)
    @invited_user_attributes = emails
  end                       

  def invited_user_attributes
    @invited_user_attributes ||= self.invited_users.*.email
  end                       
  
  def will_invite?(user)
    invited_user_attributes.include?(user.email)
  end                                        
  
  def have_invited?(user)
    invited_users.include?(user)
  end
  
  def invitee?(user)
     will_invite?(user) or have_invited?(user)
  end
        
  def set_user user
    unless self.user
      self.user = user
      save
    end
  end
                
  # Can only send invites if not a child order
  def can_send_invites?
    !is_child? and !close_timer_started?
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
      
  def confirm!
    if pending? && is_child?
      self.state = 'confirmed'
    end
  end
  
  def pay_in_shop! 
    if shop.accepts_in_shop_payments?
      print_or_queue!
    else
      raise "Shop doesn't accept in-shop payment"
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

  def print_or_queue!
    if pending?
      if shop.queues_in_shop_payments?
        order_items.each {|item| item.queue!}
        self.state = 'queued'   
      else
        order_items.each {|item| item.print!}
        self.state = 'printed'
      end
      save
    end
  end

  def invite_additional_users
    if !is_child? and self[:user_id]
      invitees = User.for_emails(invited_user_attributes)
      (invitees - invited_users.all).each {|user| invite user}
    end
  end

  def start_close_timer
    if @minutes_til_close
      self[:close_time] = @minutes_til_close.to_i.minutes.from_now
    end
  end

  def inherit_from_parent
    if is_child?
      self.state = 'invited'   
      self.shop = parent.shop
      self.perishable_token = Digest::SHA1.hexdigest("Wibble!#{rand.to_s}")
    end
  end
end
