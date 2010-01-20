#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'



def scrape(url)
  page = Nokogiri::HTML(open(url))
  page.css('.topbar .topbar table table p').map do |store|
    {}.tap do |r|
      children = store.children
      r[:name] = store.at_css("strong:nth-child(1)").text
      puts r[:name] 
      r[:street_address] = [
        children[2].text,
        store.at_css("strong:nth-child(4)").text,
        store.at_css("strong:nth-child(6)").text,
      ].select {|a| a && a.size > 0}.join(' ')
      r[:phone] = children[9].text
      r[:website]="http://www.bbscafe.com.au"
    end
  end
end


base = URI.parse("http://www.bbscafe.com.au/bbs/stores/")
page = Nokogiri::HTML(open(base))

store_links='p:nth-child(2) a'
records = page.css(store_links).map do |region|
  url = base.merge(region.attribute('href').value)
  puts url
  sleep 1
  scrape(url)
end    
               
records = []
records << scrape("http://bbscafe.com.au/bbs/stores/storeslist.asp?state=QLD&region=Brisbane")
File.open("/Users/ritchiey/franchise_data/bbs-cafe.yaml", 'w') {|f| YAML.dump(records, f)}


