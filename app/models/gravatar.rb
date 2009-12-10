require 'digest/md5'

module Gravatar    
  
  def gravatar_url options={}
    hash = Digest::MD5.hexdigest(email.downcase)   
    options = {:s=>'36', :d=>'wavatar'}.merge(options)
    params = options.to_a.map {|o| "#{o[0]}=#{o[1]}" }.join('&')
    "http://www.gravatar.com/avatar/#{hash}.jpg?#{params}"
  end
end