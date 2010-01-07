class PaymentNotification < ActiveRecord::Base                
  
  fields do
    params :text
    status :string
    transaction_id :string
    order_id :integer
    timestamps
  end
  
  
  # serialize :params
  
  def params
    self[:params] ? YAML.load(self[:params]) : nil
  end
  
  def params=(p)
    self[:params] = YAML.dump(p)
  end
  
  belongs_to :order

  after_create :confirm_order

  attr_accessible :params, :status, :transaction_id, :order_id
  
private

  def confirm_order
    if status == 'Completed'
      order.confirm_paid!
    end
  end
    
end
