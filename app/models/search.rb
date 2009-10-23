class Search
  
  attr_reader :term, :lat, :lng, :type

  def initialize(params={})
    @term = params[:term]
    @lat = params[:lat]
    @lng = params[:lng]
    @type = params[:type]
  end

  def new_record?
    true
  end        
  
  def self.human_name
    "Search"
  end                     
                             
  def coordinates_specified?
    lat.length >0 and lng.length >0
  end
  
  def shops  
    if coordinates_specified?
      Shop.find :all, :within=>5, :origin=>[lat,lng], :limit=>5, :order=>'distance'
    else
      Shop.by_name_suburb_or_postcode(@term)   
    end
  end  
  
end