class Cuisine < ActiveRecord::Base      
  
  fields do
    name  :string    
    franchise  :boolean, :default=>false
    url   :string
    regex :string
    timestamps
  end
  
  validates_presence_of :name
  
  default_scope :order=>:name
  
  attr_accessible :name, :menu_ids, :franchise, :url, :regex
  
  has_many :shop_cuisines
  has_many :shops, :through => :shop_cuisines
  has_many :cuisine_menus
  has_many :menus, :through => :cuisine_menus
  
  named_scope :is_franchise, :conditions=>{:franchise=>true}
  named_scope :is_not_franchise, :conditions=>{:franchise=>false}
  
  def self.matching_name name
    Cuisine.is_franchise.map do |franchise|
      franchise.matches_name(name) and return([franchise])
    end
    Cuisine.is_not_franchise.map do |cuisine|
      cuisine.matches_name(name) ? cuisine : nil
    end.select {|c| c }
  end
  
  
  def matches_name shop_name
    return false unless shop_name
    begin
      regexp = Regexp.new(matching_pattern, Regexp::IGNORECASE)
      regexp.match(shop_name)
    rescue RegexpError
      RAILS_DEFAULT_LOGGER.warn "Possibly invalid regex '#{regex}' on cuisine '#{name}'"
      nil
    end
  end                                                 
  
  def matching_pattern
      @matching_pattern ||= (regex and regex.strip.length > 0) ? regex : name
  end
  
end
