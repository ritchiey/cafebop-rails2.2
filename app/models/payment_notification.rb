class PaymentNotification < ActiveRecord::Base                
  
  fields do
    params :text
    status :string
    transaction_id :string
    order_id :integer
    timestamps
  end
  
  
  belongs_to :order
  serialize :params

  after_create :confirm_order

  attr_accessible :params, :status, :transaction_id, :order_id
  
private

  def confirm_order
    if status == 'Completed'
      order.confirm_paid!
    end
  end
    
end
