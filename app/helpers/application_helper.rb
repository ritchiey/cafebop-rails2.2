# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def doctype_header
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
  end

  def default_content_for(name, &block)
    name = name.kind_of?(Symbol) ? ":#{name}" : name
    out = eval("yield #{name}", block.binding)
    concat(out || capture(&block))
  end


  def placeholder(options={})
    image_tag 'transparent.png', {:alt=>''}.merge(options)
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
    markers = []
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
