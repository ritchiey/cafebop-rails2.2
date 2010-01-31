#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'



def scrape(url)
  page = Nokogiri::HTML(open(url, 'r'))
  page.css('#localListings li').map do |store|
    name = store.css('a.omnitureListingNameLink').text.strip 
    next unless name and name.size > 0
    phone = store.css('span.phoneNumber').text.sub("ph:", "").strip
    address = store.css('span.address').text.strip 
    next if address =~ /PO Box/io
    puts "#{name}, #{phone}, #{address}"
    # puts store
  end
end


scrape("/Users/ritchiey/Downloads/cafes/perth_takeaway_1.html")




