require 'yaml'

class MenuTemplate < ActiveRecord::Base
  
  fields do
    name  :string
    yaml_data :text
    timestamps
  end        
  
  def to_s
    name
  end
  
  attr_accessible :name, :yaml_data
  
  def menu_params
    YAML.load(yaml_data)
  end

end
