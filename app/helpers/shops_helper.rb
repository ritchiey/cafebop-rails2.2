module ShopsHelper

  def cuisines_for_select
    Cuisine.is_not_franchise.all.map {|c| [c.name, c.id]}
  end

  def links_for_shop(shop)
    links = [edit_shop_link(shop), order_history_link(shop),place_order_link(shop), delete_shop_link(shop)]
    if current_user.andand.can_access_queues_of?(shop)
      links += (shop.customer_queues + shop.item_queues).map {|q| link_to_unless_current(q.name, q)}
    end
    links
  end

end
