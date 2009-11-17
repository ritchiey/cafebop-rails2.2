# A menu to be displayed to the customer for ordering.
# Most menus will belong_to a shop. Those that don't are considered generic menus and should
# be associated with a cuisine. Community shops that offer that cuisine will automatically
# pick up any generic menus associated with that cuisine.
class Menu < ActiveRecord::Base

  fields do
    name      :string
    header    :string
    footer    :string
    is_extras :boolean
    community   :boolean   
    position  :integer
    timestamps
  end

  belongs_to :shop # a menu not attached to a shop is considered a generic menu
  has_many :menu_items, :dependent=>:destroy, :order=>:position
  has_many :extras_menu_for, :class_name=>"MenuItem", :foreign_key=>'extras_menu_id'
  has_many :cuisine_menus
  has_many :cuisines, :through=>:cuisine_menus

  acts_as_list :scope=>:shop

  accepts_nested_attributes_for :menu_items

  named_scope :generic, :conditions=>{:shop_id=>nil}
  named_scope :virtual_for_shop, lambda {|shop| { :joins=>["INNER JOIN cuisine_menus AS cm ON cm.menu_id = menus.id",
    "INNER JOIN shop_cuisines AS sc ON sc.cuisine_id = cm.cuisine_id"], :conditions=>["sc.shop_id = ?", shop.id] }}
  named_scope :for_franchise, lambda {|franchise| { :joins=>["INNER JOIN cuisine_menus AS cm ON cm.menu_id = menus.id"], :conditions=>["cm.cuisine_id = ?", franchise.id] }}
  named_scope :with_items, :include=>{:menu_items=>[:sizes,:flavours]}

  def generic?
    !shop_id
  end

  def deep_clone
    self.clone.tap do |cloned|
      cloned.save!
      cloned.menu_items = menu_items.map {|menu_item| menu_item.deep_clone}
    end
  end

end
