#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'



def scrape(url, out)
  page = Nokogiri::HTML(open(url, 'r'))
  page.css('#localListings li').map do |store|
    name = store.css('a.omnitureListingNameLink').text.strip 
    next unless name and name.size > 0
    phone = store.css('span.phoneNumber').text.sub("ph:", "").strip
    address = store.css('span.address').text.strip
    address.sub!(/shp\s*(\d+)/oi, 'Shop \1')
    address.sub!(/ksk\s*(\d+)/oi, 'Kiosk \1')
    address.sub!(/ShopngCntr/oi, 'Shopping Centre')
    address.sub!(/\s*\d+\s*$/oi, '')
    next if address =~ /PO Box/io
    next if name =~ /pty ltd/io
    next unless name =~ /lunch|cafe|pizza|pizzeria|away|kebab|donut/io
    next if name =~ /fine|cuisine|trust|holdings/io
    out.puts "#{name}|#{phone}|#{address}"
  end
end

def with_each_html_file_in dir
  Dir.foreach(dir) do |filename| 
    next unless filename =~ /\.html$/oi
    yield "#{dir}#{filename}"
  end
end            

File.open('/Users/ritchiey/Downloads/cafes/out.txt', 'w') do |out|
  with_each_html_file_in '/Users/ritchiey/Downloads/cafes/in/' do |filename|
    scrape filename, out
  end
end
