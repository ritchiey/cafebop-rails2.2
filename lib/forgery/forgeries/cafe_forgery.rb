# Generates random address information.
class CafeForgery < Forgery

  def self.menu_name
    dictionaries[:menu_names].random
  end   

  def self.menu_item_name
    dictionaries[:menu_item_names].random
  end   

  def self.flavour_name
    dictionaries[:flavour_names].random
  end      
  
  def self.cuisine_name
    dictionaries[:cuisine_names].random
  end
  
  def self.size_name
    dictionaries[:size_names].random
  end
  
end
 
