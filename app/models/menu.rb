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

  belongs_to :shop
  has_many :menu_items, :dependent=>:destroy, :order=>:position
  has_many :extras_menu_for, :class_name=>"MenuItem", :foreign_key=>'extras_menu_id'

  acts_as_list :scope=>:shop

  accepts_nested_attributes_for :menu_items

end
