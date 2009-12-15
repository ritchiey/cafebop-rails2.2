module ShopsHelper

def claim_shop_link(shop)
  shop.can_be_claimed? ? ( link_to_unless_current('Claim this Shop', new_shop_claim_path(shop)) {""} ) : ""
end

def edit_shop_link(shop) 
  shop.can_edit?(current_user) ? ( link_to_unless_current('Edit', edit_shop_path(shop)) {""} ) : ""
end

def cuisines_for_select
  Cuisine.is_not_franchise.all.map {|c| [c.name, c.id]}
end

end
