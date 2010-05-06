class ShopObserver < ActiveRecord::Observer
  
  include Geokit::Geocoders
  
  def before_validation shop
    if shop.new_record? or shop.changes['street_address']
      if res = MultiGeocoder.geocode(shop.street_address)
        shop.lat, shop.lng, shop.location_accuracy = res.lat, res.lng, res.accuracy
      end
    end
  end        
  
  def after_save(shop)
    case shop.changes['accept_queued_orders']
      when [false, true]
        RAILS_DEFAULT_LOGGER.info "Queuing enabled for shop #{shop.id}"
        Notifications.send_later(:deliver_queuing_enabled, shop)
    end
    true
  end
  
  def after_create(shop)
    if !shop.active? and shop.owner
      Notifications.send_later(:deliver_activate_shop, shop)
    end
    true
  end
  
end
