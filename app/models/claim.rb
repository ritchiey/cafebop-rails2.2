class Claim < ActiveRecord::Base

  fields do     
    notes :text    
    state :string, :default=>'pending'
    first_name  :string
    last_name   :string
    timestamps
  end

  belongs_to :user
  belongs_to :shop
  belongs_to :reviewer, :class_name=>'User'
                  
  default_scope :order=>'created_at DESC'
  named_scope :pending, :conditions=>{:state=>'pending'}
  named_scope :under_review, :conditions=>{:state=>'under_review'}
  named_scope :confirmed, :conditions=>{:state=>'confirmed'}
  named_scope :rejected, :conditions=>{:state=>'rejected'}
  named_scope :outstanding, :conditions=>{:state=>['pending', 'under_review']}
  named_scope :for_shop, lambda {|shop| {:conditions=>{:shop=>shop}}}

  attr_accessor :agreement
  
  attr_accessible :user, :notes, :first_name, :last_name, :agreement
  
  def validate_on_create
    unless shop.can_be_claimed_by?(user)
      errors.add_to_base("#{shop} can't be claimed by #{user}")
    end
    unless agreement =~ /i agree/oi
      errors.add_to_base("You must enter 'I Agree' in the agreement box.")
    end
    unless !notes or notes.empty?
      errors.add_to_base("Now why would you do that?")
    end
  end

  validates_presence_of :first_name, :last_name, :on=>:create

  def to_s
    "#{first_name} #{last_name} claims #{shop.to_s}"
  end


  # --- Lifecycle --- #
  
  def pending?() self.state == 'pending'; end
  def under_review?() self.state == 'under_review'; end
  def confirmed?() self.state == 'confirmed'; end
  def rejected?() self.state == 'rejected'; end   
  def outstanding?() pending? or under_review?; end

  def review!(reviewer)
    if pending?
      self.reviewer = reviewer
      self.state = 'under_review'
      self.save
    end
  end

  def confirm!
    if under_review?
      shop.claim!(user)
      self.state = 'confirmed'
      if self.save
        Notifications.send_later(:deliver_claim_confirmed, self)
      end
    end
  end

  def reject!
    if under_review?
      self.state = 'rejected'
      if self.save
        Notifications.send_later(:deliver_claim_rejected, self)
      end
    end
  end                        
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted? 
    return false if shop_changed? or user_changed?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field) 
    return true if user_is? acting_user
    acting_user.administrator?
  end

end
