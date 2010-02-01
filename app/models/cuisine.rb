class Cuisine < ActiveRecord::Base      
  
  fields do
    name  :string    
    franchise  :boolean, :default=>false
    url   :string
    regex :string
    timestamps
  end
  
  default_scope :order=>:name
  
  attr_accessible :name, :menu_ids, :franchise, :url, :regex
  
  has_many :shop_cuisines
  has_many :shops, :through => :shop_cuisines
  has_many :cuisine_menus
  has_many :menus, :through => :cuisine_menus
  
  named_scope :is_franchise, :conditions=>{:franchise=>true}
  named_scope :is_not_franchise, :conditions=>{:franchise=>false}
  
  def self.matching_name name
    Cuisine.regex_not_null.map do |cuisine|
      cuisine.matches_name(name) ? cuisine : nil
    end.select {|c| c }
  end
  
  
  def matches_name name
    return false unless name and regex and regex.strip.length > 0
    begin
      regexp = Regexp.new(regex, Regexp::IGNORECASE)
      regexp.match(name)
    rescue RegexpError
      RAILS_DEFAULT_LOGGER.warn "Possibly invalid regex '#{regex}' on cuisine '#{name}'"
      nil
    end
  end
  
end
