var jQT = $.jQTouch({ 
	cacheGetRequests: false,
	icon: '/images/icon.png',
	formSelector: 'form.ajax',
	statusBar: 'black-translucent',
	preloadImages: [
	]
});								  

// fix JQTouch 1.0 beta 2
// When enabled, this prevents problems with double taps but
// disables animation for some reason.
// (function(){
//     var goTo = jQT.goTo;
//     jQT.goTo = function(page) {
//         if ($(page).hasClass("current")) {
//             return;
//         }
//         return goTo(page);
//     }
// })();


var app = { 
  as_currency: function(amount)
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
	$.ajax({
	 type: options['method'] || form.attr('method'),
	 url: options['url'] || form.attr('action'),
	 data:form.serialize(),
	 complete: options['onComplete'] || function() {},
	 dataType: options['dataType'] || 'json',
	});
  },

  loadDynamicPage: function(pageSelector, localObjectName, options) {
	var titleSelector = pageSelector + ' .title';
	var listSelector = pageSelector + ' .list';
	var serverObjectName = options['serverObjectName'] || localObjectName;
	var serverControllerName = options['serverControllerName'] || (serverObjectName + 's')
	var getTitle = options['getTitle'] || function(obj) {return obj.name};
	var entryToHtml = options['entryToHtml'] || function(subObj, subCollectionName) {
	  return app.listLink(subObj.name, 'to-'+subCollectionName, subObj.id);
	}

	if (!options['noLoading']) {
  	$(titleSelector).text('Loading...');
	}
	if (app.isLoggedIn()) {
	  app.getContent("/"+serverControllerName+"/"+app[localObjectName+'_id']+"/", function(data) {
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
		    entries.push((options['emptyListEntry'] || function() {})(subCollectionName))
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
	$(pageSelector).bind('pageAnimationEnd', function(e, info) {
	   if (info.direction == 'out') {
		 (options['onExit'] || function() {})(pageSelector, info)
	   } else {
		 (options['onEntry'] || function() {})(pageSelector, info);
	   }
	});
  },
 
  bindLink: function(linkSelector, pageSelector, beforeRender) {
	$(linkSelector).tap(function(e) {
	  beforeRender(e);
	  jQT.goTo(pageSelector, 'slide');
	  return false;
	});
  },
  
  deliverOrder: function($form) {
	app.submitForm($form, {
	  url: '/orders/'+app.queued_order_id+'/deliver',
	  onComplete: function(req) {
		if (req.status == 200 && req.responseText != 'false') {
		  jQT.goBack();
		} else {
		  alert("Unable to deliver order. Try again.");
		}
	  }
	})
  },
  
  makeQueuedOrderItem: function($form) {
	app.submitForm($form, {
	  onComplete: function(req) {
		if (req.status == 200 && req.responseText != 'false') {
		  jQT.goBack();
		} else {
		  alert("Unable to make order item. Try again.");
		}
	  }
	})
	return false; 
  },

  loadHome: function() {
	if (app.isLoggedIn()) {
	  app.getContent("/", function(data) { 
		var $shopList = $('.my-restaurants');
		var shopListEntries = jQuery.map(data.work_contracts, function(el) {
		  var wc = el.work_contract;
		  var shop = wc.shop;
		  return app.listLink(shop.name, 'to-show-shop', shop.id);
		});
		$shopList.empty();
		$shopList.append(shopListEntries.join(''));
	  })
	} else {
	  alert('Not logged in so clearing home!');
	  app.clearHomePage();
	}
  },
  
  loadShowShop: function() {
	$('#shop-name').text('Loading...');
	if (app.isLoggedIn()) {
	  app.getContent("/shops/"+app.shop_id+"/", function(data) {
		var shop = data.shop;
		$('#shop-name').text(shop.name);
		var customerQueueListEntries = jQuery.map(shop.customer_queues, function(queue) {
		  return app.listLink(queue.name, 'to-show-customer-queue', queue.id);
		});
		var $queueList = $('#queue-list');
		$queueList.empty();
		$queueList.append(customerQueueListEntries.join(''));
	  });
	}
  },
 
  loadShowCustomerQueue: function(options) {
    options = $.extend({}, {
  	  getTitle: function(queue) {return queue.name},
  	  entryToHtml: function(order) {
  		return app.listLink(order.name, 'to-show-queued-order', order.id, {
  		  subLink: order.summary
  		})},
  		emptyListEntry: function() {
  		  return "<li>Queue is empty</li>"
  		}
  	}, (options || {}));
  	app.loadDynamicPage('#show-customer-queue', 'customer_queue', options);
  },   


  loadShowQueuedOrder: function() {
	var $made_order_controls = $('#show-queued-order .made-order-controls')
	$made_order_controls.hide();
	app.loadDynamicPage('#show-queued-order', 'queued_order', {
	  serverObjectName: 'order',
	  serverControllerName: 'queued_orders',
	  // store the order for use when showing order items
	  withLoadedObject: function(order) {
	  $('#show-queued-order .order-status').text(((order.state == 'made')? "Ready for ":"For ")+order.effective_name)
		app.current_order = order
		if (order.state == 'made') {
		  $made_order_controls.show();
		}
	  },
	  getTitle: function(order) {return "Order"},
	  entryToHtml: function(order_item, list_name, index) {
		return app.listLink(order_item.quantity+' '+order_item.description,
		  'to-show-queued-order-item', index, {
			li_classes: 'arrow '+order_item.state,
			subLink: order_item.notes,
			counter: app.as_currency(order_item.price_in_cents /100.0)
		  })
	  }
	});
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
	)
	
	// app.loadDynamicPage('#show-queued-order-item', 'queued_order_item', {
	//	 serverControllerName: 'queued_order_items',
	//	 serverObjectName: 'order_item',
	//	 getTitle: function(order_item) {return order_item.description}
	// })
  },

  clearHomePage: function() {
	// TODO: Remove all items from the home page
	alert('clearing home page');
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
	})
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

  $('#make-order-item-form').submit(function(e) {
	var $form = $(this);
	return app.makeQueuedOrderItem($form);
  });  

  $('form#login').submit(function(e) {
	var $form = $(this);
	return app.login($form);
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
	app.interval_id = window.setInterval(function() {app.loadShowCustomerQueue({'noLoading': true})}, 5000);
  },
  onExit: function() {
	window.clearInterval(app.interval_id)
  }
});
app.addPage('show', 'queued-order', {onEntry: app.loadShowQueuedOrder});
app.addPage('show', 'queued-order-item', {onEntry: app.loadShowQueuedOrderItem});
