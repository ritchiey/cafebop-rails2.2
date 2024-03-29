require 'csv'

# A menu to be displayed to the customer for ordering.
# Most menus will belong_to a shop. Those that don't are considered generic menus and should
# be associated with a cuisine. Community shops that offer that cuisine will automatically
# pick up any generic menus associated with that cuisine.
class Menu < ActiveRecord::Base

  fields do
    name      :string
    description :string
    permalink :string
    header    :string
    footer    :string
    is_extras :boolean
    community :boolean   
    position  :integer
    timestamps
  end

  belongs_to :shop # a menu not attached to a shop is considered a generic menu
  has_many :menu_items, :dependent=>:destroy, :order=>:position
  has_many :extras_menu_for, :class_name=>"MenuItem", :foreign_key=>'extras_menu_id'
  has_many :cuisine_menus
  has_many :cuisines, :through=>:cuisine_menus

  acts_as_list :scope=>:shop

  accepts_nested_attributes_for :menu_items, :allow_destroy=>true, :reject_if=>lambda {|m| m[:name].blank?} 

  named_scope :generic, :conditions=>{:shop_id=>nil}
  named_scope :virtual_for_shop, lambda {|shop| { :joins=>["INNER JOIN cuisine_menus AS cm ON cm.menu_id = menus.id",
    "INNER JOIN shop_cuisines AS sc ON sc.cuisine_id = cm.cuisine_id"], :conditions=>["sc.shop_id = ?", shop.id] }}
  named_scope :for_franchise, lambda {|franchise| { :joins=>["INNER JOIN cuisine_menus AS cm ON cm.menu_id = menus.id"], :conditions=>["cm.cuisine_id = ?", franchise.id] }}
  named_scope :with_items, :include=>{:menu_items=>[:sizes,:flavours]}

  def self.import_csv(prefix, csv_data, shop_id=nil)
    first = true
    menu_name = nil
    menu_items_attributes = []
    CSV.parse(csv_data) do |row|
      if first # ignore first line
        first = false
        next
      end
      
      next if row.all? {|c| !c or c.strip.length == 0} # ignore blank lines
      (new_menu_name, item_name, description, price_str, flavours_str) = *row
      
      if item_name and item_name.strip.length > 0
        record = {
          :name=>item_name,
          :description=>description,
          :price=>price_str
        }
        if flavours_str and flavours_str.strip.length > 0
          record.merge!(:flavours_attributes=>flavours_str.split(',').map {|f| {:name=>f.strip}})
        end
        menu_items_attributes << record
      end
      next unless new_menu_name and new_menu_name.strip.length > 0
      if (new_menu_name != menu_name)
        make_menu(prefix, menu_name, menu_items_attributes, shop_id)
        menu_name = new_menu_name
        menu_items_attributes = []
      end
    end
    make_menu(prefix, menu_name, menu_items_attributes, shop_id)
  end             
  
  def self.make_menu(prefix, menu_name, menu_items_attributes, shop_id)
    permalink = "#{prefix} - #{menu_name}"
    if menu_name and menu_items_attributes.size > 0
      menu = Menu.create(:permalink=>permalink,
        :name=>menu_name,
        :menu_items_attributes=>menu_items_attributes,
        :shop_id=>shop_id)
    end
  end

  def generic?
    !shop_id
  end

  def managed_by? user
    user.manages? shop_id
  end
  
  def deep_clone
    self.clone.tap do |cloned|
      cloned.save!
      cloned.menu_items = menu_items.map {|menu_item| menu_item.deep_clone}
    end
  end

end
