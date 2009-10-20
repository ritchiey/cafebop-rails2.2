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


  def placeholder
    image_tag 'transparent.png', :alt=>''
  end
end
