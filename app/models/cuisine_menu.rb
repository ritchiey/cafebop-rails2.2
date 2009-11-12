class CuisineMenu < ActiveRecord::Base
  belongs_to :cuisine
  belongs_to :menu
end
