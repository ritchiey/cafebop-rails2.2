#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'yaml'

url = "http://www.bbscafe.com.au/bbs/stores/storeslist.asp?state=QLD&region=Brisbane"

doc = Nokogiri::HTML(open(url))

records=doc.css('.topbar .topbar table table p').map do |store|
  {}.tap do |r|
    children = store.children
    r[:name] = store.at_css("strong:nth-child(1)").text
    r[:street_address] = [
      children[2].text,
      store.at_css("strong:nth-child(4)").text,
      store.at_css("strong:nth-child(6)").text,
    ].select {|a| a && a.size > 0}.join(' ')
    r[:phone] = children[9].text
    r[:website]="http://www.bbscafe.com.au"
  end
end

File.open("/Users/ritchiey/franchise_data/bbs-brisbane.yaml", 'w') {|f| YAML.dump(records, f)}
