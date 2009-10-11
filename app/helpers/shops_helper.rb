module ShopsHelper

def edit_shop_link(shop) 
  shop.can_edit?(current_user) ? link_to('Edit', edit_shop_path(shop)) : ""
end

end
