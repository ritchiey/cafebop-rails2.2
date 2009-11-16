class CuisineMenu < ActiveRecord::Base
  
  fields do
    timestamps
  end
  
  belongs_to :cuisine
  belongs_to :menu
end
