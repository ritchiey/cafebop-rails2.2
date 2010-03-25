
var cb = {
  addNotice: function(message) {
    var notice = "<div class='notice'>"+message+"<img src='/images/remove.gif' class='close-btn' alt='close'></div>"
    $('#notifications').append(notice);
  },                                      
  
  requestSignup: function() {
    this.showSignup();
    this.requestAuth();
    $('#user_email').focus();
    $('#user_email').select();
  },
  
  requestLogin: function() {
    this.showLogin();
    this.requestAuth();
    $('#user_session_email').focus();
    $('#user_session_email').select();
  },
  
  requestAuth: function() {
    $('#authForm').dialog('open');
  },
  
  showSignup: function() {
    $('#authForm').dialog('option', 'title', 'Sign Up');
    $('#authForm').dialog('option', 'width', 700);
    $('#authForm').dialog('option', 'height', 675);
    $('#authForm .login').hide();
    $('#authForm .signup').show();
  },
  
  showLogin: function() {
    $('#authForm').dialog('option', 'title', 'Login');
    $('#authForm').dialog('option', 'width', 400);
    $('#authForm').dialog('option', 'height', 450);
    $('#authForm .login').show();
    $('#authForm .signup').hide();
  }
  
};

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
  
  $('.make-account-blurb').hide();
  
  setTimeout(function() {
    $('.make-account-blurb').slideDown();
    }, 1500);
     
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

  $(".add-shop .add-btn").each(function(i) {
    $(this).click(function() {return false;})
    $(this).qtip({
    content: $('#quick-add-shop'),
    position: qtipRight(),   
    style: {   
      width: 400,
      tip: 'leftMiddle',
      name: 'cafebop'
    },
    show: jQuery.extend(qtipShow(), {
      when: {
        event: 'click'
      }
    }),
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
  
  setTimeout(function() {$('#flash').slideDown();}, 500);

  $("#friendship_friend_email").val('email').focus(function () {
    $(this).select();
  });
  $("#search_term").select().focus();
  $("#order_effective_name").select().focus();
  
  $("form.order").validate();

  

  $("form.made-order").live('click', function(e) {
    $(this).ajaxSubmit({
      dataType: 'json',
      success: function(json) {},
      beforeSubmit: function(formData, jqForm, options) {
        jqForm.closest('tbody').fadeOut();
      }
    });

    return false;
  });
    
  function ajaxSubmitError(data, status, e) {
    alert('Error submitting form'+
    'data: '+ data +
    'status: ' + status +
    'e : '+ e
    );
  }
      
  $("form.order-item").submit(function(e) {
    options = {
      url: $(e.target).attr('action') + '?fragment=order',
      dataType: 'html',
      success: function(html) {$(e.target).closest('tbody').replaceWith(html);},
      error: ajaxSubmitError,
      beforeSubmit: function(formData, jqForm, options) {
        jqForm.children('input').replaceWith('<span>(made)</span>');
      }
    };
    $(this).ajaxSubmit(options);
    return false;
  });
    

	$('#vote-blurb').dialog({
			bgiframe: true,
			autoOpen: true,
			height: 450,
      width: 650,
			modal: true,
			buttons: {
				'Vote!': function() {
					$(this).dialog('close');
					var $form = $('#vote-blurb form');  
          $.ajax({
           type: $form.attr('method'),
           url: $form.attr('action'),
           data: $form.serialize(),
           success: function(data, textStatus, XMLHttpRequest) { 
             var vote = data.vote;
             var shop = vote.shop;
             
             cb.addNotice('Thanks for your feedback. Your vote places, "Get an accurate menu for '+
              shop.name+'" at number '+shop.ranking+' on our To Do list.');
           },
           dataType: 'json'
          });
        },
        "Cancel": function() {
					$(this).dialog('close');
        }
      }
  });
  


 
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
  
  $('.close-btn').live('click', function() {
    var notice = $(this).closest('.notice');
    notice.hide();
  });
  
  $('.accuracy-warning').live('click', function() {
    
    return false;
  });

  $('.remove').live('click', function(e) {
    var tr = $(this).closest('tr');
    var id = $(tr).find('input#order_order_items_attributes__id').attr('value');
    var menu_item_id = $(tr).find('input#order_order_items_attributes__id').attr('value');
    var quantity = $(tr).find('input#order_order_items_attributes__quantity').attr('value');
    var size_id = $(tr).find('input#order_order_items_attributes__size_id').attr('value');
    var flavour_id = $(tr).find('input#order_order_items_attributes__flavour_id').attr('value');
    var form = $(this).closest('form');
    tr.remove();  
    update_continue_order_button();
    update_total();
    if (id) {
      form.prepend("<input type='hidden' name='order[order_items_attributes][][id]' value='"+id+"' />");
      form.prepend("<input type='hidden' name='order[order_items_attributes][][menu_item_id]' value='"+menu_item_id+"' />");
      form.prepend("<input type='hidden' name='order[order_items_attributes][][quantity]' value='"+quantity+"' />");
      form.prepend("<input type='hidden' name='order[order_items_attributes][][size_id]' value='"+size_id+"' />");
      form.prepend("<input type='hidden' name='order[order_items_attributes][][flavour_id]' value='"+flavour_id+"' />");
      form.prepend("<input type='hidden' name='order[order_items_attributes][][_delete]' value='true' />");
    }
  });
            
  $('#authForm').dialog({
    autoOpen: false,
    height: 500,
    width: 500
  });

  $('#authForm .show-signup').click(function(e) {
    $('#authForm').dialog('close');
    cb.requestSignup()
    return false;
  });

  $('#authForm .show-login').click(function(e) {
    $('#authForm').dialog('close');
    cb.requestLogin()
    return false;
  });

  $('#pay-in-shop-button.to-queue').click(function(e) {
    if (current_user) {
      return true;
    } else {
      cb.requestSignup();
      return false;
    }
  });   
  
  $('#offer-friends-button').click(function(e) {
    if (current_user) {
      return true;
    } else {
      cb.requestSignup();
      return false;
    }
  });   
  
  $('#login-btn').click(function(e) {
    cb.requestLogin();
    return false;
  });

  $('#signup-btn').click(function(e) {
    cb.requestSignup();
    return false;
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
                    "</td><td class='cost'>"+cost(menu_item)+
                    "</td><td class='remove'><img src='/images/remove.gif' alt='remove' /></td></tr>"+
                    (notes ?
                      "<tr class='notes'><td colspan='4' class='notes'>" + notes +
                      "<input type='hidden' name='order[order_items_attributes][][notes]' value='"+notes+"'>" +
                      "</td></tr>"
                    :
                      ""
                    )
                    );
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
  return "http://"+toPermalink(name) +"."+ domain_name + "/";
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
  $('.close-early').hide();
}


    
function keyCode(str) {
  return str.charCodeAt(0);
}                          

function printable(code) {
  return (32 <= code && code <= 126) ? String.fromCharCode(code) : false;
}
 
// Queue Navigation
// $('#collection-section table tbody tr:first').focus();
// 
// $('#collection-section table').keypress(function(e) {
//   switch (printable(e.which)) {
//     case 'J': // down
//     case 'j': // down
//       alert("You pressed 'j'")
//       break;
//     case keyCode('K'): // up
//     case keyCode('k'): // up
//       alert("You pressed 'k'")
//       break;
//   };
// });


  