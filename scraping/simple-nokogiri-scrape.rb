require 'rubygems'
require 'nokogiri'
require 'open-uri'



url = "http://www.bbscafe.com.au/bbs/stores/storeslist.asp?state=QLD&region=Brisbane"
doc = Nokogiri::HTML(open(url))

doc.css('.topbar .topbar table table p').each do |store|
  children = store.children
  name = store.at_css("strong:nth-child(1)").text
  address1 = children[2]
  address2 = store.at_css("strong:nth-child(4)").text
  address3 = store.at_css("strong:nth-child(6)").text
  phone = children[9]
  
  p "#{name}: #{address1} #{address2} #{address3}:#{phone}"
end
