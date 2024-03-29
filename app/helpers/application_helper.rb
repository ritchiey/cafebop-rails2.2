# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def admin_link_to *args
    admin? ? link_to(*args) : ''
  end

  def link_to_refund_policy(shop, label=nil)
    (shop && shop.refund_policy && shop.refund_policy.strip.length > 0) ? link_to((label || "Refund Policy"), refund_policy_for_shop_path(shop), :target=>'_new') : ""
  end                             
  
  def link_to_site_terms(label="Terms")
    link_to label, site_terms_content_url(:subdomain=>false), :target=>'_new'
  end
  
  def link_to_faq(label="FAQ")
    link_to label, faq_content_url(:subdomain=>false), :target=>'_new'
  end
  
  def link_to_credits(label="About")
    link_to label, credits_content_url(:subdomain=>false), :target=>'_new'
  end
  
  def link_to_privacy_policy(label="Privacy")
    link_to label, privacy_policy_content_url(:subdomain=>false), :target=>'_new'
  end

  def button_link_to name, url, html_options={}
    link_to name, url,{:class=>'btn'}.merge(html_options)
  end

  def button_link_to_unless_current name, url, html_options={}
    link_to_unless_current(name, url,{:class=>'btn'}.merge(html_options)) {""}
  end
  

  # Generate a hash containing the order or shop ids if available.
  # Use to append to links where these details must be preserved
  def with_order_or_shop(order, shop) 
    r = {} 
    if order and order.id
      r.merge!({:order_id=>order.id})
    else
      r.merge!({:shop_id=>shop.id}) if shop and shop.id
    end
    r
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

  def edit_shop_link(shop)
    current_user.andand.can_edit_shop?(shop) ? (link_to_unless_current('Edit', shop_edit_path(@shop)) {""} ) : nil
  end                            
  
  def delete_shop_link(shop)
    current_user.andand.can_delete_shop?(shop) ? (link_to 'Delete', shop_path(shop), :method=>:delete, :confirm=>"Really delete #{shop}?") : ''
  end

  def order_history_link(shop)
    shop.can_view_history?(current_user) ? (link_to_unless_current('Order History', shop_past_orders_path(shop)) {""} ) : nil
  end                            
  
  def place_order_link(shop) 
    (link_to_unless_current('New Order', shop_new_order_path(shop)) {""} )
  end                            
  
  def separated(links, separator=' | ')
    links.select {|l| l and l.length > 0}.join(separator)
  end
         
                                            
  def page_background
    if @shop and @shop.border_background.file?
      "url(#{@shop.border_background.url}) #{@shop.tile_border ? "repeat":"no-repeat"} #D0D4C2"
    else
      "url(/gradient_images/250:B9C2A0:D0D4C2.png) repeat-x #D0D4C2"
    end
  end
  
  def header_background
    if shop_with_header?
      "url(#{@shop.header_background.url(:header)}) no-repeat #FEFEFD"
    else
      if @shop
        "url(/gradient_images/180:4474AB:FEFEFD.png) repeat-x #FEFEFD"
      else
        "rgba(255,255,255,0)"
        # "url(/images/logo.png) no-repeat" 
      end
    end
  end

  def placeholder(options={})
    image_tag 'transparent.gif', {:alt=>''}.merge(options)
  end   
  
  def import_google_api
    javascript_include_tag "http://www.google.com/jsapi?key=#{GOOGLE_API_KEY|| 'ABQIAAAAuTvlrqlJASuyCXRw3N66QRRZbV2-gr_MZFFc9gOZTwY2NgbmaxQzSGWr6zxZ9lUzBS56We3R9gG5Dw'}&ignore="
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
    image_tag "http://maps.google.com/staticmap?#{params.join '&'}", :alt=>"map", :id=>'static-map'
  end                        
  
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class=>'remove-control')
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end
  
  
  private

    def valid_location?(loc)
      loc && loc.lat && !loc.lat.empty? && loc.lng && !loc.lng.empty?
    end

end
