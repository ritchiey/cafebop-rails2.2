module OrdersHelper

  def cuisine_names(shop)
    shop.cuisines.map {|c| c.name }.join('/')
  end
  
end
