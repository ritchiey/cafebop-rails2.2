class OrderItem < ActiveRecord::Base

  

  fields do
    description :string
    quantity :integer
    price    :integer   
    notes    :string    
    state    :string
    timestamps
  end

  belongs_to :item_queue
  belongs_to :order
  belongs_to :menu_item
  belongs_to :size
  belongs_to :flavour
 
  def user() order.user; end
  

end
