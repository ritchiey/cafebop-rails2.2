class Stat

  attr_accessor :shop, :user
  
  def initialize
    @user = user
    @shop = shop
  end
  
  def user
    {
      :total => User.count
    }
  end
  
  def shop
    {
      :total => Shop.count,
      :express => Shop.express.count,
      :professional => Shop.professional.count,
      :with_no_cuisine => Shop.number_with_no_cuisine
    }
  end                       

  def order
    {
      :total => Order.count,
      :last_hour => Order.created_at_gt(1.hour.ago).count,
      :last_24_hours => Order.created_at_gt(24.hours.ago).count
    }
  end
end