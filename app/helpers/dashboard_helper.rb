module DashboardHelper

     
  # Return an array of entries of the form ['label', 'value'] from a
  # set of keys and a hash.
  # The keys can be either symbols, strings (converted to symbols for the hash) or
  # two entry arrays of the form ['label', :key].
  def tabulate(keys, values)
    keys.map {|key| key.kind_of?(Array) ? [key[0], values[key[1].to_sym]] : [key.to_s.capitalize, values[key.to_sym]]}
  end

  def user_rows
    tabulate([[link_to('Users', users_path), 'total']], @stat.user)
  end

  def shop_rows
    tabulate([[link_to('Shops', shops_path), :total], :community, :express, :professional, [link_to("With no cuisine", cuisineless_shops_path), :with_no_cuisine]], @stat.shop)
  end        
  
  def claim_rows
    tabulate([[link_to('Claims',claims_path), :total], :outstanding, :pending, ["Under review", :under_review], :confirmed, :rejected], @stat.claim)
  end

  def order_rows
    tabulate([['Orders', :total], ["Last 24 hours", :last_24_hours], ["Last hour", :last_hour]], @stat.order)
  end



end
