require 'active_record/fixtures'
require 'yaml'


menu_templates = [
{                :name=>'Cafe Drinks',
                 :yaml_data=>YAML.dump({
                   :name=>'Drinks',
                   :menu_items_attributes=>[
                       {:name=>'Coffee',
                        :flavours_attributes=>[
                          {
                            :name=>'Flat White',
                            :description=>'Frothy Perfection'
                          },
                          {
                            :name=>'Cappucino',
                            :description=>'Frothy Perfection plus chocolate sprinkles'
                          }
                          ], # flavours_attributes
                        :sizes_attributes=>[
                            { :name=>'Regular', :price=>'3.80' },
                            { :name=>'Large', :price=>'4.50' }
                          ]
                        }
                     ]
                   })
}
]
menu_templates.each {|mt| MenuTemplate.find_or_create_by_name(mt)}     

# This is no longer necessary because we're using Google maps API for
# geolocation.
#
# Suburb.delete_all
# Dir.glob(RAILS_ROOT + '/db/fixtures/*.{yml,csv}').each do |file|
#   Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
# end  

[
  'Chinese',
  'Pasta',
  'Pizza',
  "Fish'n'Chips",
  'Thai',
  'Italian',
  'Coffees',
  'French',
  'Vegitarian',
  'Vegan',
  'Steakhouse',
  'Indian',
  'Desserts',
  'Japanese',
  'Hamburgers',
  'Mexican',
  'Other'
].each {|cuisine| Cuisine.find_or_create_by_name(cuisine)}