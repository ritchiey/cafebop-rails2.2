class Stat

  attr_accessor :shop, :user, :claim
  
  def initialize
    @user = user
    @shop = shop
    @claim = claim
  end
  
  def user
    {
      :total => User.count
    }
  end
  
  def shop
    {
      :total => Shop.count,
      :community => Shop.community.count,
      :express => Shop.express.count,
      :professional => Shop.professional.count
    }
  end                       

  def claim
    {
      :total => Claim.count,
      :outstanding => Claim.count,
      :pending => Claim.pending.count,
      :under_review=> Claim.under_review.count,
      :confirmed=> Claim.confirmed.count,
      :rejected=> Claim.rejected.count
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