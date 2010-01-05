module ShopsHelper

def cuisines_for_select
  Cuisine.is_not_franchise.all.map {|c| [c.name, c.id]}
end

end
