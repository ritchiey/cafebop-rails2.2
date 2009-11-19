require 'rubygems'
require 'scrapi'

scraper = Scraper.define do
  process "title", :page_name=>:text
  result :page_name
end                

uri = URI.parse("http://www.aromacafe.com.au/cafes.php?pno=0") 
puts scraper.scrape(uri)