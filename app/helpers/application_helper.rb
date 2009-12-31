# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def button_link_to name, url, html_options={}
    link_to name, url,{:class=>'btn'}.merge(html_options)
  end

  def button_link_to_unless_current name, url, html_options={}
    link_to_unless_current(name, url,{:class=>'btn'}.merge(html_options)) {""}
  end

  def doctype_header
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
  end

  def default_content_for(name, &block)
    name = name.kind_of?(Symbol) ? ":#{name}" : name
    out = eval("yield #{name}", block.binding)
    concat(out || capture(&block))
  end


  def shop_with_header?
    @shop and @shop.header_background.file?
  end                  
          
#3E84BC
#8CBAD0          
                                            
  def page_background
    "url(/gradient_images/250:B9C2A0:D0D4C2.png) repeat-x #D0D4C2"
  end
  
  def header_background
    if shop_with_header?
      "url(#{@shop.header_background.url(:header)}) no-repeat #FEFEFD"
    else
      if @shop
        "url(/gradient_images/180:4474AB:FEFEFD.png) repeat-x #FEFEFD"
      else
        "url(/images/logo.png) no-repeat" 
      end
    end
  end

  def placeholder(options={})
    image_tag 'transparent.gif', {:alt=>''}.merge(options)
  end   
  
  def import_google_api
    javascript_include_tag "http://www.google.com/jsapi?key=#{GOOGLE_API_KEY}&ignore="
    #%Q{<script src="http://maps.google.com/maps?file=api&v=2&sensor=false&key=#{GOOGLE_API_KEY}" type="text/javascript"></script>}
  end   
  
  def static_map options={}  
    center = options[:center]
    places = options[:places] || []                    
    width = options[:width] || 300
    height = options[:height] || width
    markers = options[:markers] || []
    places.each_with_index {|p,i| markers<<"#{p.lat},#{p.lng},blue#{i+1}"}  
    valid_location?(center) and markers << "#{center.lat},#{center.lng},red"
    params = [
      "size=#{width}x#{height}",
      "maptype=mobile",
      "sensor=false",
      "markers=#{markers.join '|'}",
      "key=#{GOOGLE_API_KEY}"
    ]
    valid_location?(center) and params << "center=#{center.lat},#{center.lng}"
    image_tag "http://maps.google.com/staticmap?#{params.join '&'}", :alt=>"map"
  end                        
  
  private

    def valid_location?(loc)
      loc && loc.lat && !loc.lat.empty? && loc.lng && !loc.lng.empty?
    end

end
