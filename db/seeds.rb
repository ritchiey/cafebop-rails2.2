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
menu_templates.each {|mt| MenuTemplate.create(mt)}
