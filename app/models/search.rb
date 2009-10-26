class Search
  
  attr_reader :term, :lat, :lng, :cuisine

  def initialize(params={})
    @term = params[:term]
    @lat = params[:lat]
    @lng = params[:lng]
    @cuisine = params[:cuisine]
  end

  def new_record?
    true
  end        
  
  def self.human_name
    "Search"
  end                     
                             
  def coordinates_specified?
    lat && lat.length >0 and lng && lng.length >0
  end  
  
  def cuisine_specified?
    @cuisine && !@cuisine.empty?
  end
  
  def shops              
    scope = Shop.scoped({})
    scope = scope.scoped :include=>[:shop_cuisines], :conditions=>["shop_cuisines.cuisine_id = ?", @cuisine] if cuisine_specified?
    scope = scope.scoped :conditions=>["#{Shop.distance_sql(self)} < 6"] if coordinates_specified?
    scope
  end
      
  #   if cuisine_specified?
  #     if coordinates_specified?
  #       Shop.find :all, :include=>[:shop_cuisine], :within=>5, :origin=>[lat,lng], :limit=>5, :order=>'distance', :include=>[:shop_cuisines], :conditions=>["shop_cuisines.cuisine_id=?", @cuisine]
  #     else
  #       Shop.by_name_suburb_or_postcode(@term).find :all, :include=>[:shop_cuisines], :conditions=>["shop_cuisines.cuisine_id=?", @cuisine]
  #     end
  #   else
  #     if coordinates_specified?
  #       Shop.find :all, :within=>5, :origin=>[lat,lng], :limit=>5, :order=>'distance'
  #     else
  #       Shop.by_name_suburb_or_postcode(@term).find :all
  #     end
  #   end
  # end  
  
end