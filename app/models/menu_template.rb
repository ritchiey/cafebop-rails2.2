class MenuTemplate < ActiveRecord::Base
  
  fields do
    name  :string
    yaml_data :text
    timestamps
  end
  
  attr_accessible :name, :yaml_data
end
