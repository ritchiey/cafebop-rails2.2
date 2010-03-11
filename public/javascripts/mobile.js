Date.fromSecondsSinceEpoch = function(seconds) {
  return new Date(seconds * 1000);
};

Date.prototype.distance_of_time_in_minutes = function(to) {
  var distance_in_milliseconds = Math.abs(to.valueOf() - this.valueOf());
  return Math.round(distance_in_milliseconds / 60000);
}

Date.prototype.distance_of_time_in_words = function(to) {
  var distance_in_minutes = this.distance_of_time_in_minutes(to);
  var words;
  if (distance_in_minutes == 0) {
    words = "less than a minute";
  } else if (distance_in_minutes == 1) {
    words = "1 minute";
  } else if (distance_in_minutes < 45) {
    words = distance_in_minutes + " minutes";
  } else if (distance_in_minutes < 90) {
    words = "about 1 hour";
  } else if (distance_in_minutes < 1440) {
    words = "about " + Math.round(distance_in_minutes / 60) + " hours";
  } else if (distance_in_minutes < 2160) {
    words = "about 1 day";
  } else if (distance_in_minutes < 43200) {
    words = Math.round(distance_in_minutes / 1440) + " days";
  } else if (distance_in_minutes < 86400) {
    words = "about 1 month";
  } else if (distance_in_minutes < 525600) {
    words = Math.round(distance_in_minutes / 43200) + " months";
  } else if (distance_in_minutes < 1051200) {
    words = "about 1 year";
  } else {
    words = "over " + Math.round(distance_in_minutes / 525600) + " years";
  }
  return words;
};

Date.prototype.time_ago_in_words = function() {
  return this.distance_of_time_in_words(new Date());
}; 

Date.prototype.time_ago_in_minutes = function() {
  return this.distance_of_time_in_minutes(new Date());
};


var jQT = $.jQTouch({ 
	cacheGetRequests: false,
	icon: '/images/icon.png',
	formSelector: 'form.ajax',
	statusBar: 'black-translucent',
	preloadImages: [
	'/images/smallbubble.png'
	]
});								  

// this prevents problems with double taps
(function(){
    var goTo = jQT.goTo;
    jQT.goTo = function(page, animation) {
        if ($(page).hasClass("current")) {
            return;
        }               
        return goTo(page, animation);
    }
})();  


var app = { 
  as_currency: function(amount) {
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
  },
  
  underscore: function(src) {
  	return src.replace(/-/g, "_" );
  },

  getContent: function(url, success) {
  	$.ajax({
  	  type: 'GET',
  	  success: success,
  	  url: url, 
  	  dataType: 'json'
  	});
  },
  
  submitForm: function(form, options) {
  	options = options || {}
  	var onComplete = options['onComplete'] || function(req) {
    	if (req.status == 200 && req.responseText != 'false') {
    	  jQT.goBack();
    	} else {
    	  alert(options['failMessage'] || "Unable to perform. Try again.");
    	}
    }
  
  	$.ajax({
  	 type: options['method'] || form.attr('method'),
  	 url: options['url'] || form.attr('action'),
  	 data:form.serialize(),
  	 complete: onComplete,
  	 dataType: options['dataType'] || 'json',
  	});
  }, 
  
  showLoading: function(pageSelector) {
    app.hideLoading();
    $(pageSelector).prepend("<img src='/images/loading.gif' id='loading'>")
  },

  hideLoading: function() {
    $('#loading').remove();
  },

  loadDynamicPage: function(pageSelector, localObjectName, options) {
    var loadingSelector = options['loadingSelector'] || '#loading';
  	var titleSelector = pageSelector + ' .title';
  	var listSelector = pageSelector + ' .list';
  	var serverObjectName = options['serverObjectName'] || localObjectName;
  	var serverControllerName = options['serverControllerName'] || (serverObjectName + 's')
  	var getTitle = options['getTitle'] || function(obj) {return obj.name};
  	var entryToHtml = options['entryToHtml'] || function(subObj, subCollectionName) {
  	  return app.listLink(subObj.name, 'to-'+subCollectionName, subObj.id);
  	}
  	var emptyList = options['emptyListEntry'] || function() {return "<li>No entries</li>"}

  	if (!options['noLoading']) {
  	  app.showLoading(pageSelector);
    	$(titleSelector).text('Loading...');
  	}
  	if (app.isLoggedIn()) {
  	  app.getContent("/"+serverControllerName+"/"+app[localObjectName+'_id']+"/", function(data) {
      app.hideLoading(pageSelector);
  		var obj = data[serverObjectName]
  		options['withLoadedObject'] && options['withLoadedObject'](obj);
  		// Set page title
  		$(titleSelector).text(getTitle(obj));
		
  		// Populate each list on the page
  		$(pageSelector + ' .item-list').each(function(index, itemList) {
  		  var subCollectionName = app.underscore($(itemList).attr('id'));
  		  if (subCollectionName == null) return; // todo throw exception here
  		  if (obj[subCollectionName] == null)  return; // todo throw exception
  		  var entries = jQuery.map(obj[subCollectionName], function(subObj, index) {
  			return entryToHtml(subObj, subCollectionName, index);
  		  });
  		  $(itemList).empty();
  		  if (entries.length == 0) {
  		    entries.push(emptyList(subCollectionName))
  		  } 
  		  $(itemList).append(entries.join(''));
  		});
  	  });
  	}
  },   

  listLink: function(label, a_classes, target_id, options) {
  	options = options || {};
  	var li_classes = options['li_classes'] || 'arrow';
  	var small = (options['small']) ? ("<small>"+options['small']+"</small>") : ""
  	var counter = (options['counter']) ? ("<small class='counter'>"+options['counter']+"</small>") : ""
  	var link = function(l) {
  	  return (l != null) ? ("<a class='"+a_classes+"'"+
  	  " href='#' target-id='"+target_id+
  	  "'>"+l+"</a>") : "";
  	}
  	return "<li class='"+li_classes+"'>"+
  	  link(label) +
  	  link(options['subLink']) +
  	  small +
  	  counter+
  	  "</li>";
  },


  // Register a static page ('#verb-noun') that may load dynamic data
  // when displayed. Also hook the tap event on any a.to-verb-noun links
  // and set an variable app.noun_id to be the value taken from the 'target-id'
  // attribute of the link.
  addPage: function(verb, noun, options) {	
  	var pageSelector = '#'+verb+'-'+noun
  	$(function() {app.bindPage(pageSelector, options)});
  	app.bindLink('a.to-'+verb+'-'+noun, pageSelector, function(e) {
  	  app[app.underscore(noun)+'_id'] = $(e.target).attr('target-id');
  	});
  },
  
  bindPage: function(pageSelector, options) {
  	$(pageSelector).bind('pageAnimationStart', function(e, info) {
  	   if (info.direction == 'in') {
  	     app.clonePage(pageSelector);
  	   }
    });
    
  	$(pageSelector).bind('pageAnimationEnd', function(e, info) {
  	   if (info.direction == 'out') {
  	     app.restoreClonedPage(pageSelector);
    		 (options['onExit'] || function() {})(pageSelector, info)
  	   } else {
    		 (options['onEntry'] || function() {})(pageSelector, info);
  	   }
  	});
  },
  
  clonePage: function(selector) {
    var varName = app.underscore('clone_of_'+selector)
    if (!app[varName]) {  
      app[varName] = $(selector).html();
    }
  },
  
  restoreClonedPage: function(selector) {
    var varName = app.underscore('clone_of_'+selector)
    if (app[varName]) {
      $(selector).empty()
      $(selector).append(app[varName])
    }
  },
 
  bindLink: function(linkSelector, pageSelector, beforeRender) {
  	$(linkSelector).tap(function(e) {
  	  beforeRender(e);
  	  jQT.goTo(pageSelector, 'slide');
  	  return false;
  	});
  },

  makeAllItems: function($form) {
  	app.submitForm($form, {
  	  url: '/queued_orders/'+app.queued_order_id+'/make_all_items',
  	  failMessage: "Unable to make. Try again."
  	})
  },
  
  deliverOrder: function($form) {
  	app.submitForm($form, {
  	  url: '/orders/'+app.queued_order_id+'/deliver',
  	  failMessage: "Unable to deliver order. Try again."
  	})
  },
  
  makeQueuedOrderItem: function($form) {
  	app.submitForm($form, {
  	  failMessage: "Unable to make order item. Try again."
  	});
  	return false; 
  },

  loadHome: function() {
  	if (app.isLoggedIn()) {
  		$('#home .unauthenticated').hide();
  	  app.getContent("/", function(data) { 
  		var $shopList = $('.my-restaurants');
  		var shopListEntries = jQuery.map(data.work_contracts, function(el) {
  		  var wc = el.work_contract;
  		  var shop = wc.shop;
  		  return app.listLink(shop.name, 'to-show-shop', shop.id);
  		});
  		$shopList.empty();
  		$shopList.append(shopListEntries.join(''));
  		$('#home .authenticated').show();
  	  })
  	} else {
  	  app.clearHomePage();
  	}
  },
  
  loadShowShop: function(options) {
    options = $.extend({}, {
      entryToHtml: function(obj, listName) {
        return app.listLink(obj.name, 'to-show-customer-queue', obj.id);
      }
  	}, (options || {}));
  	app.loadDynamicPage('#show-shop', 'shop', options);
  },
 
  loadShowCustomerQueue: function(options) {
    options = $.extend({}, {
  	  getTitle: function(queue) {return queue.name},
  	  entryToHtml: function(order) {
  		return app.listLink(order.name, 'to-show-queued-order', order.id, {
  			li_classes: 'arrow ' + order.state,
  		  subLink: order.summary,
  			counter: app.as_currency(order.grand_total)
  		})},
  		emptyListEntry: function() {
  		  return "<li>Queue is empty</li>"
  		}
  	}, (options || {}));
  	app.loadDynamicPage('#show-customer-queue', 'customer_queue', options);
  },   


  loadShowQueuedOrder: function() {
  	var $order_controls = $('#show-queued-order .order-controls');
  	var $deliver = $('#show-queued-order .deliver');
  	var $make_all_items = $('#show-queued-order .make-all-items');
  	app.loadDynamicPage('#show-queued-order', 'queued_order', {
  	  serverObjectName: 'order',
  	  serverControllerName: 'queued_orders',
  	  // store the order for use when showing order items
  	  withLoadedObject: function(order) {
    	  $('#show-queued-order .order-status').text(((order.state == 'made')? "Ready for ":"For ")+order.effective_name)
    	  app.updateOrderAge(order);
      	app.order_interval_id = window.setInterval(function() {app.updateOrderAge(order);}, 5000);
    		app.current_order = order;
    		$('.cancel-order').show();
    		if (order.state == 'made') {
    		  $deliver.show();
    		  $make_all_items.hide();
    		} else {
    		  $deliver.hide();
    		  $make_all_items.show();
    		}
  		  $('#show-queued-order .total').text('Total: $'+ app.as_currency(order.grand_total));
  		  $order_controls.show();
  	  },
  	  getTitle: function(order) {return "Order"},
  	  entryToHtml: function(order_item, list_name, index) {
  		return app.listLink(order_item.quantity+' '+order_item.description,
  		  'to-show-queued-order-item', index, {
  			li_classes: order_item.state,
  			subLink: order_item.notes,
  			counter: app.as_currency(order_item.quantity * order_item.price_in_cents / 100.0) +
  			  " <input type='checkbox' class='made-check' name='made' " +
  			    ((order_item.state=='made')? "CHECKED ":"") +
  			    " value='" + index+ "'></input>"
  		  })
  	  }
  	});
  },

  updateOrderAge: function(order) {
	  var queued_at = Date.fromSecondsSinceEpoch(order.queued_at_utc);
	  var age_text = "Received " + queued_at.time_ago_in_words()+' ago';
	  if (age_text != order.age_text) {
  	  $('.order-received').text(age_text);
	    order.age_text = age_text;
	  }
	  if (queued_at.time_ago_in_minutes() >= 15) {
	    $('.no-show').show();
	  } else {
	    $('.no-show').hide();
	  }
  },

  loadShowQueuedOrderItem: function() {			  
  	// Because this is a summarized order_item, it can contain multiple order_item ids
  	// id in its 'ids' field
  	var order_item = app.current_order.summarized_order_items[app.queued_order_item_id]
  	var $order_items = $('#show-queued-order-item .order-items')
  	var $item_details = $('#show-queued-order-item .item-details')
  	var $item_notes = $('#show-queued-order-item .item-notes')
  	$('#show-queued-order-item .title').text(order_item.quantity+" "+order_item.description)
  	$item_details.text(order_item.quantity+" "+order_item.description)
  	$item_notes.text(order_item.notes || '')
  	$order_items.empty()
  	$order_items.append(
  	  $.map(order_item.ids, function(item_id) {
  		return "<input type='hidden' name='order_item_ids[]' value='"+item_id+"'></input>"
  	  }).join('')
  	);
  },

  clearHomePage: function() {
    $('#home .authenticated').hide();
		$('.my-restaurants').empty();
    $('#home .unauthenticated').show();
  },
  
  isLoggedIn: function() {
  	return (user != null && user.length > 0);
  },
  
  login: function($form) {
  	app.submitForm($form, {
  	  onComplete:function(req) {
  		 if (req.status == 200 && req.responseText != 'false') { 
  		  user = req.responseText;
  		  app.updateFormControls();
  		  jQT.goBack();
  		 } else {
  		   alert("Couldn't login. Try again.");
  		 }
  	  }
  	});
  },

  updateFormControls: function() {
  	if (app.isLoggedIn()) {
  	  $('#login-button').hide();
  	  $('#logout-button').show();
  	} else {
  	  $('#login-button').show();
  	  $('#logout-button').hide();
  	}
  }
  
};		   

$('.made-check').tap(function(e) {
  var index = $(this).attr('value');
  var order_item = app.current_order.summarized_order_items[index];
  var data = {};
  $.each(order_item.ids, function(i, e) {data['order_item_ids[]'] = e});
  $.ajax({
   type: 'POST',
   url: '/queued_order_items/make_all',
   data: $.param(data, true),
   complete: function(XMLHttpRequest, textStatus) {
   },
   dataType: 'json',
  });
  return true;
});


$('a.no-show').tap(function(e) {
  if (confirm('Register a no-show for this order?')) {
    var $form = $(this).closest("form");
  	app.submitForm($form, {
  	  url: '/queued_orders/'+app.queued_order_id+'/no_show'
  	})
  }
  return false;
});               


$('a.cancel-order').tap(function(e) {
  if (confirm('Really cancel order?')) {
    var $form = $(this).closest("form");
  	app.submitForm($form, {
  	  url: '/queued_orders/'+app.queued_order_id+'/cancel'
  	})
  }
  return false;
});

$('a.make-all-items').tap(function(e) {
  var $form = $(this).closest("form");
  app.makeAllItems($form);
  return false;
});


$('a.deliver').tap(function(e) {
  var $form = $(this).closest("form");
  app.deliverOrder($form);
  return false;
});

$('a.make').tap(function(e) { 
  var $form = $(this).closest("form");
  app.makeQueuedOrderItem($form);
  return false;
});

$('a.login').tap(function(e) {
  var $form = $(this).closest("form");
  return app.login($form);	 
});

$(function() { // on page ready   
  // Record home page whilst in a pristine state
  app.clonePage('#home');

  $('#make-order-item-form').submit(function(e) {
	var $form = $(this);
	return app.makeQueuedOrderItem($form);
  });  

  $('form#login').submit(function(e) {
  	var $form = $(this);
  	app.login($form);
  	return false;
  });  
  
  $('#logout-button').tap(function(e) {
	var $form = $('form#logout');
	app.submitForm($form, {
	  onComplete: function(req) {
		user = null;
		app.updateFormControls();
		app.clearHomePage(); 
		jQT.goBack('#home');
	  }
	});
  });
  
  app.updateFormControls();	 


  // Setup load events for each page
  app.bindPage('#home', {onEntry: app.loadHome});

  // Dynamically populate the homepage
  app.loadHome();
});

app.addPage('show', 'shop', {onEntry: app.loadShowShop});
app.addPage('show', 'customer-queue', {
  onEntry: function() {
  	app.loadShowCustomerQueue();
  	app.interval_id = window.setInterval(function() {app.loadShowCustomerQueue({'noLoading': true})}, 20000);
  },
  onExit: function() {
	window.clearInterval(app.interval_id);
  }
});
app.addPage('show', 'queued-order', {
  onEntry: app.loadShowQueuedOrder,
  onExit: function() {
	window.clearInterval(app.order_interval_id);
  }
  });
app.addPage('show', 'queued-order-item', {onEntry: app.loadShowQueuedOrderItem});
