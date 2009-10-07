class Claim < ActiveRecord::Base

  fields do     
    notes :text    
    state :string, :default=>'pending'
    timestamps
  end

  belongs_to :user
  belongs_to :shop
  belongs_to :reviewer, :class_name=>'User'
                  
  default_scope :order=>'created_at DESC'
  named_scope :pending, :conditions=>{:state=>'pending'}
  named_scope :outstanding, :conditions=>{:state=>['pending', 'under_review']}
  named_scope :for_shop, lambda {|shop| {:conditions=>{:shop=>shop}}}

  def to_s
    "#{user.to_s} claims #{shop.to_s}"
  end


  # --- Lifecycle --- #
  
  def pending?() self.state == 'pending'; end
  def under_review?() self.state == 'under_review'; end
  def confirmed?() self.state == 'confirmed'; end
  def rejected?() self.state == 'rejected'; end

  def review!(reviewer)
    if pending?
      self.reviewer = reviewer
      self.state = 'under_review'
    end
  end

  def confirm!
    if under_review?
      shop.claim!(user)
      self.state = 'confirmed'
    end
  end

  def reject!
    if under_review?
      self.state = 'rejected'
    end
  end                        
  
  #TODO Reimplement lifecycle
  # lifecycle do
  #   state :pending, :default=>true
  #   state :under_review, :confirmed, :rejected
  # 
  #   transition :review, {:pending => :under_review},
  #     :available_to=>"User.administrator",
  #     :user_becomes=>:reviewer      
  # 
  #   transition :reject, {:under_review=>:rejected},
  #     :available_to=>:reviewer do
  #       UserMailer.deliver_claim_rejected(self)
  #     end
  # 
  #   transition :confirm, {:under_review=>:confirmed},
  #     :available_to=>:reviewer do  
  #     wc= shop.work_contracts.find(:first, :conditions=>{:user_id=>acting_user})
  #     wc ||= shop.work_contracts.build(:user=>acting_user, :role=>'manager')
  #     wc.role = 'manager'
  #     wc.save!
  #     shop.lifecycle.confirm_claim!(acting_user,{})
  #     UserMailer.deliver_claim_confirmed(self)
  #   end
  # 
  # end   


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
