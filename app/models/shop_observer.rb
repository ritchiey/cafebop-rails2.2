class ShopObserver < ActiveRecord::Observer
  
  include Geokit::Geocoders
  
  def before_validation shop
    if shop.new_record? or shop.changes['street_address']
      if res = MultiGeocoder.geocode(shop.street_address)
        shop.lat, shop.lng, shop.location_accuracy = res.lat, res.lng, res.accuracy
      end
    end
  end        
  
  def after_create shop
    Cuisine.regex_not_null.each do |cuisine|
      begin
        regex = Regexp.new(cuisine.regex, Regexp.IGNORECASE)        
        regex.match(shop.name) and shop.shop_cuisines << cuisine
      rescue                    
        RAILS_DEFAULT_LOGGER.warn "Possibly invalid regex '#{cuisine.regex}' on cuisine '#{cuisine.name}'"
      end
    end
  end
end
