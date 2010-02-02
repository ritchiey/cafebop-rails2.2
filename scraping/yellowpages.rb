#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'



def scrape(url, out_file)
  File.open(out_file, 'w') do |out|
    page = Nokogiri::HTML(open(url, 'r'))
    page.css('#localListings li').map do |store|
      name = store.css('a.omnitureListingNameLink').text.strip 
      next unless name and name.size > 0
      phone = store.css('span.phoneNumber').text.sub("ph:", "").strip
      address = store.css('span.address').text.strip 
      next if address =~ /PO Box/io
      next if name =~ /pty ltd/io
      next unless name =~ /lunch|cafe|pizza|pizzeria|away|kebab|donut/io
      next if name =~ /fine|cuisine/io
      out.puts "#{name}|#{phone}|#{address}"
    end
  end
end

def with_each_html_file_in dir
  Dir.foreach(dir) do |filename| 
    next unless filename =~ /\.html$/oi
    yield "#{dir}#{filename}"
  end
end            

with_each_html_file_in '/Users/ritchiey/Downloads/cafes/in/' do |filename|
  dest_name = filename.sub(/\/in\//, '/out/').sub(/\.html/, '.txt')   
  puts dest_name
  scrape filename, dest_name
end





