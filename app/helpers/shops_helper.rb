module ShopsHelper

def edit_shop_link(shop) 
  shop.can_edit?(current_user) ? ( link_to_unless_current('Edit', edit_shop_path(shop)) {""} ) : ""
end

end
