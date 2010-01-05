var country_code = 'au';
var domain_name = '.cafebop.com';


function showControlsAsNeeded() {
  jQuery("tr").hover(
      function() {     
          jQuery(this).find(".controls").show()
      },
      function() {     
          jQuery(this).find(".controls").hide()
      }
  )
}

var dialog, quantity_field, size_field, notes_field, details_field, order_items, total;

function qtipShow() {
  return {
    solo: true,
    type: 'fade',
    length: 400
  };
};

function qtipHide() {
  return {
    delay: "1000",
    fixed: true, 
    type: 'fade',
    length: 400
  };
};                   

function qtipRight() {
  return {
    corner: {
      target: 'rightMiddle',
      tooltip: 'leftMiddle'
    }
  };
};

function qtipLeft() {
  return {
    corner: {
      target: 'leftMiddle',
      tooltip: 'rightMiddle'
    }
  };
};


$.fn.qtip.styles.cafebop = {
    width: 200,
    textAlign: 'left',
    border: {
      width: 7,
      radius: 5
    },
    name: 'dark'
};

$(function() { // page ready   
  $('body').supersleight({shim: '/images/transparent.gif'});
  
  $(".search-result").each(function(i) {
    $(this).qtip({
    content: $(this).siblings(".tooltip"),
    position: qtipRight(),   
    style: {
      tip: 'leftMiddle',
      name: 'cafebop'
    },
    show: qtipShow(),
    hide: qtipHide()
    });
    });  

        
  $(".shop-entry").each(function(i) {
    $(this).qtip({
    content: $(this).siblings(".tooltip"),
    position: qtipLeft(),   
    style: {
      tip: 'rightMiddle',
      name: 'cafebop'
    },
    show: qtipShow(),
    hide: qtipHide()
    });
  });  
  
  $(".friend-entry").each(function(i) {
    $(this).qtip({
    content: $(this).siblings(".tooltip"),
    position: qtipLeft(),   
    style: {
      tip: 'rightMiddle',
      name: 'cafebop'
    },
    show: qtipShow(),
    hide: qtipHide()
    });
  });     
    
  $(function(){
      $('a.info').click(function(){
          window.open(this.href);
          return false;
      });
  });
  
  $('#flash').click(function() {
    $(this).slideUp();
    return false;
  })
  
  setTimeout(function() {$('#flash').slideDown();}, 2000);
  
    
    // $("a.info").each(function(i) {    
    //   $(this).bind('click', function() {return false;});
    //   $(this).qtip({
    //     content: {
    //       text: "Loading...",
    //       url: $(this).attr("href") + "?no_frame=true"
    //     },   
    //     style: {      
    //       width: 600,
    //       name: 'cafebop'
    //     },    
    //     position: {  
    //       target: $('#content-body'),
    //       corner: {
    //         tooltip: 'topLeft',
    //         target: 'topLeft'
    //       },
    //       adjust: {screen: true}
    //     },
    //     show: {
    //       when: {event: 'click'}
    //     },
    //     hide: qtipHide()
    //   });
    // }
    //   );

         


  $('tr.friend').hover(
    function() {
      $(this).find('.remove-btn').show();
    },
    function() {
      $(this).find('.remove-btn').hide();
    }
  );

	          
  dialog = $('#dialog');
  quantity_field = $('#quantity_field');
  size_field = $('#size_field');
  flavour_field = $('#flavour_field');
  notes_field = $('#notes_field');
  details_field = $('#details_field');
  order_items = $('#order_items');
  total = $('#total');
      
	dialog.dialog({
			bgiframe: true,
			autoOpen: false,
			height: 300,
                        width: 400,
			modal: true,
			buttons: {
				'Add to order': function() {
					$(this).dialog('close');
					add_to_order();
      }
    }
  });
    
  $('.remove').live('click', function(e) {
    var tr = $(this).closest('tr');
    var id = $(tr).find('input#order_order_items_attributes__id').attr('value');
    var form = $(this).closest('form');
    tr.remove();  
    update_continue_order_button();
    update_total();
    if (id) {
      form.append("<input type='hidden' name='order[order_items_attributes][][id]' value='"+id+"'");
      form.append("<input type='hidden' name='order[order_items_attributes][][_delete]' value='true'");
    }
  });

});    


// This sets up the proper header for rails to understand the request type,
// and therefore properly respond to js requests (via respond_to block, for example)
$.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

$(document).ready(function() {

  // UJS authenticity token fix: add the authenticy_token parameter
  // expected by any Rails POST request.
  $(document).ajaxSend(function(event, request, settings) {
    // do nothing if this is a GET request. Rails doesn't need
    // the authenticity token, and IE converts the request method
    // to POST, just because - with love from redmond.
    if (settings.type == 'GET') return;
    if (typeof(AUTH_TOKEN) == "undefined") return;
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });

});


function flavour_id() {
  return selected_id('flavour_field');
}

function size_id() {
  return selected_id('size_field');
}
         
function add_to_order() { 
  var order_item = order_item_from_json(details_field.val());
  var menu_item = order_item.menu_item;  
  var quantity = quantity_field.val();
  var notes = notes_field.val();
  order_items.append("<tr><td>"+ quantity +
                    "<input type='hidden' name='order[order_items_attributes][][quantity]' value='"+quantity+"'>"+   
                    "<input type='hidden' name='order[order_items_attributes][][menu_item_id]' value='"+menu_item.id+"'>"+                    
                    (flavour_id() ? ("<input type='hidden' name='order[order_items_attributes][][flavour_id]' value='"+flavour_id()+"'>") : "")+   
                    (size_id() ? ("<input type='hidden' name='order[order_items_attributes][][size_id]' value='"+size_id()+"'>") : "")+   
                    "</td><td>"+description(menu_item)+
                    "</td><td>" +(notes ?
                      "<img href='/images/notes.png' alt='"+notes+"'" +
                      "<input type='hidden' name='order[order_items_attributes][][notes]' value='"+notes+"'>"
                    :
                      ""
                    )+"</td>" +
                    "</td><td class='cost'>"+cost(menu_item)+
                    "</td><td class='remove'>x</td></tr>");
  update_continue_order_button();
  update_total();
}
                              
function update_continue_order_button() {
  if ($('#order_items .cost').length > 0) {
    $('#continue-order-button').enable();
  } else {
    $('#continue-order-button').disable();
  }
}                                  

function selected(select_field_id) {
  return $('#'+select_field_id+' option:selected');
}

function selected_text(select_field_id) {
  var option = selected(select_field_id);
  return (option && option.val())? option.text()+" " : "";
}

function selected_id(select_field_id) {
  var option = selected(select_field_id);
  return (option && option.val())? option.val() : null;
}   

function index_by(key, list) {
  result = {};
  for (i in list) {
    record = list[i];
    result[record[key]] = record;
  }                              
  return result;
}

function as_currency(amount)
{
	var i = parseFloat(amount);
	if(isNaN(i)) { i = 0.00; }
	var minus = '';
	if(i < 0) { minus = '-'; }
	i = Math.abs(i);
	i = parseInt((i + .005) * 100);
	i = i / 100;
	s = new String(i);
	if(s.indexOf('.') < 0) { s += '.00'; }
	if(s.indexOf('.') == (s.length - 2)) { s += '0'; }
	s = minus + s;
	return s;
}


function cost(menu_item) {
  var price, quantity;
  quantity = parseInt(quantity_field.val(), 10);
  var size_id = selected_id("size_field");
  price = parseInt(size_id ? index_by('id', menu_item.sizes)[size_id].price_in_cents : menu_item.price_in_cents, 10);
  return as_currency(price * quantity / 100.0);
}  

function total_cost() {       
  var total = 0.0;
  $('#order_items .cost').each(function(i) {
    var amount = this.textContent;
    total += parseFloat(amount);
  });
  return total;
}      

function update_total() {
    total.html(as_currency(total_cost()));
}

function description(menu_item) {
  var desc = "";
  desc += selected_text("size_field");
  desc += selected_text("flavour_field"); 
  desc += menu_item.name;
  return desc;
}
                                                             
function options_from_sizes(sizes) {
  options = "";
  for (var i in sizes) {
    options += "<option value='"+sizes[i].id+"'>"+sizes[i].name+"</option>";
  } 
  return options;
}


function option_from_flavour(flavour, selected) {
  return "<option value='"+flavour.id+"'"+
    (selected ? "selected = 'selected' ": "")
  +">"+flavour.name+"</option>";
}

function options_from_flavours(flavours) {
  options = "";  
  var first = true;
  for (var i in flavours) {
    options += option_from_flavour(flavours[i], first);
    first = false;
  } 
  return options;
}
                 
function show_or_hide(menu_item, attr) {
  var element = $('#'+attr+'_details');         
  var menu_item_attr = menu_item[attr+'s'];
  if (menu_item_attr && menu_item_attr.length > 0)
    element.show();
  else
    element.hide();
}                                            

function order_item_from_json(json) {
  return eval("("+json+")").order_item;
}                                                 

function title_for(order_item) {
  return (order_item.flavour? order_item.flavour.name+" " : "") +
         order_item.menu_item.name;
}

function popup(json) {
  var order_item = order_item_from_json(json);
  var menu_item = order_item.menu_item;   
  quantity_field.val("1");
  details_field.val(json);
  notes_field.val("");
  dialog.data('title.dialog', title_for(order_item));  
  show_or_hide(menu_item, 'size');
  show_or_hide(menu_item, 'flavour');
  size_field.html(options_from_sizes(menu_item.sizes));
  flavour_field.html(order_item.flavour ? option_from_flavour(order_item.flavour)
    : options_from_flavours(menu_item.flavours)); 
  dialog.dialog('open');
}      

// Google Maps related

function displayShop(point, address, shopName) {
  map.setCenter(point, 13);
  var marker = new GMarker(point);
  map.addOverlay(marker);
  marker.openInfoWindowHtml("<h1>"+shopName+"</h1>" +address);      
}

function geocode(address, shopName) {
  geocoder.getLatLng(address, function(point) {
    if (!point) {
      alert("Couldn't find your street address in the map.");
    } else {                   
      $('#shop_lat').val(point.lat());
      $('#shop_lng').val(point.lng());
      displayShop(point, address, shopName);
    }
  })
}

function toPermalink(name) {
  name = name.replace(/[ _]/g, "-");
  name = name.replace(/[!@#$%^&*()\']/g, "");
  return name.toLowerCase();
}     

function toShopUrl(name) {
  return "http://"+toPermalink(name) + domain_name + "/";
}     

function initialize_geocoder() {
  geocoder = new GClientGeocoder();   
  geocoder.setBaseCountryCode(country_code)
}
                   
function initialize_map() {
  map = new google.maps.Map2(document.getElementById("map"));
  map.setCenter(new google.maps.LatLng(-31.96637,115.90049), 13);
}

function initialize_shop_form_map() {
  initialize_map();
  initialize_geocoder();
  
  var lat = $('#shop_lat').val();
  var lng = $('#shop_lng').val();
  var name = $('#shop_name').val();
  var address = $('#shop_street_address').val();
  if (lat.length > 0 && lng.length > 0) {
    displayShop(new GLatLng(lat, lng), address, name);
  }      
}

function make_sortable(item, container, container_id) {
$('#'+item+'-list').sortable(
  {
    items: 'li',
    opacity: 0.4,
    scroll: true,
    update: function(){
      $.ajax({
          type: 'post', 
          data: $('#'+item+'-list').sortable('serialize'), 
          dataType: 'script', 
          complete: function(request){
              $('#'+item+'-list').effect('highlight');
            },
          url: '/'+container+'/'+container_id+'/reorder_'+item.replace('-','_')})
      }
  })                    
}

function order_timer_expired() {
  $('.order-closed').show("slow");   
  $('.order-closed').removeAttr('disabled')
}
    

