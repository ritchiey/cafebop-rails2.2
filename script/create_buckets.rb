#!/usr/bin/ruby

require 'rubygems'
require 'aws/s3'

include AWS::S3
Base.establish_connection!(
  :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)                        
                                    
%w/cafebop_development cafebop_test cafebop_staging cafebop_prod cafebop_au/.each do |bucket|
  Bucket.create(bucket)
end
