class ShopObserver < ActiveRecord::Observer
  
  include Geokit::Geocoders
  
  def before_validation shop
    if shop.new_record? or shop.changes['street_address']
      if res = MultiGeocoder.geocode(shop.street_address)
        shop.lat, shop.lng, shop.location_accuracy = res.lat, res.lng, res.accuracy
      end
    end
  end        
  
end
