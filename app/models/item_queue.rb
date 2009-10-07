class ItemQueue < ActiveRecord::Base



  fields do
    name :string
    timestamps
  end    
  
  belongs_to :shop
  has_many :menu_items, :dependent=>:nullify
  has_many :order_items
  has_many :current_items, :class_name=>'OrderItem', :foreign_key=>'item_queue_id', :order=>"created_at ASC", :conditions=>{:state =>'queued'}

  validates_length_of :name, :minimum=>1


  # --- Permissions --- #

  def create_permitted?
    return true if shop.community_managed? && shop.item_queues.empty?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def update_permitted?
    return false if shop_changed?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def destroy_permitted?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def view_permitted?(field)
    acting_user.administrator? || shop.is_staff?(acting_user)
  end

end
