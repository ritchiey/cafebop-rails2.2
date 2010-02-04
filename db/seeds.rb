require 'active_record/fixtures'
require 'yaml'

menu_templates = YAML::load_file('db/fixtures/menu_templates.yml')   
menu_templates.each {|mt| MenuTemplate.find_or_create_by_name(mt)}     

# This is no longer necessary because we're using Google maps API for
# geolocation.
#
# Suburb.delete_all
# Dir.glob(RAILS_ROOT + '/db/fixtures/*.{yml,csv}').each do |file|
#   Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
# end  

[
  ['Chinese',         'chinese|palace|golden'],
  ['Pasta',           'pasta|italian'],
  ['Pizza',           'pizza|pizzeria|italian'],
  ["Fish'n'Chips",    'fish|chips'],
  ['Thai',            'thai'],
  ['Coffees',         'coffee|cafe|caffe|[sx]presso|latte|bean|cino'],
  ['French',          'french'],
  ['Vegetarian',      'vegetarian'],
  ['Vegan',           'vegan'],
  ['Steakhouse',      'steak|beef|\Wbull\W'],
  ['Juice Bar',       'juice'],
  ['Sushi Bar',       'sushi'],
  ['Kebabs',          'kebab'],
  ['Lunch Bar',       'lunch'],
  ['Indian',          'indian'],
  ['Japanese',        'japan|nippon'],
  ['Hamburgers',      'burger'],
  ['Mexican',         'mexican|taco'],
  ['Other'            ''],
].each {|c| cuisine = Cuisine.find_or_create_by_name(c[0]); cuisine.regex = c[1]; cuisine.save!}


franchises = YAML::load_file('db/fixtures/franchises.yml')
franchises.each { |e| e[:name].strip!; Cuisine.find_or_create_by_name(e) }
