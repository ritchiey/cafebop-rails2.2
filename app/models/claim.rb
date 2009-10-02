class Claim < ActiveRecord::Base



  fields do     
    notes :text    
    state :string
    timestamps
  end

  belongs_to :user
  belongs_to :shop
  belongs_to :reviewer, :class_name=>'User'

  named_scope :outstanding, :conditions=>{:state=>['pending', 'under_review']}
  named_scope :for_shop, lambda {|shop| {:conditions=>{:shop=>shop}}}
  

  def to_s
    "#{user.to_s} claims #{shop.to_s}"
  end


  # --- Lifecycle --- #
  
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
