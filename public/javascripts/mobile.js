var jQT = $.jQTouch({ 
    cacheGetRequests: false,
    icon: '/images/icon.png',
    formSelector: 'form.ajax',
    statusBar: 'black-translucent',
    preloadImages: [
    ]
});                               


var app = { 
  
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
    
    $(titleSelector).text('Loading...');
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
          // alert('obj[subCollectionName] = '+obj[subCollectionName].length);
          var entries = jQuery.map(obj[subCollectionName], function(subObj, index) {
            return entryToHtml(subObj, subCollectionName, index);
          });
          $(itemList).empty();
          $(itemList).append(entries.join(''));
        });
      });
    }
  },   

  listLink: function(label, a_classes, target_id, options) {
    options = options || {};
    var li_classes = options['li_classes'] || 'arrow';
    var link = function(l) {
      return (l != null) ? ("<a class='"+a_classes+"'"+
      " href='#' target-id='"+target_id+
      "'>"+l+"</a>") : "";
    }
    return "<li class='"+li_classes+"'>"+
      link(label) +
      link(options['subLink']) +
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
 
  loadShowCustomerQueue: function() {
    app.loadDynamicPage('#show-customer-queue', 'customer_queue', {
      getTitle: function(queue) {return queue.name},
      entryToHtml: function(order) {
        return app.listLink(order.name, 'to-show-queued-order', order.id, {
          subLink: order.summary
        });
      }
    });
  },   


  loadShowQueuedOrder: function() {
    app.loadDynamicPage('#show-queued-order', 'queued_order', {
      serverObjectName: 'order',
      serverControllerName: 'queued_orders',
      // store the order for use when showing order items
      withLoadedObject: function(order) {app.current_order = order},
      getTitle: function(order) {return order.effective_name},
      entryToHtml: function(order_item, list_name, index) {
        return app.listLink(order_item.quantity+' '+order_item.description,
          'to-show-queued-order-item', index, {li_classes: 'arrow '+order_item.state})
      }
    });
  },


  loadShowQueuedOrderItem: function() {           
    // Because this is a summarized order_item, it can contain multiple order_item ids
    // id in its 'ids' field
    var order_item = app.current_order.summarized_order_items[app.queued_order_item_id]
    var $order_items = $('#show-queued-order-item .order-items')
    $('#show-queued-order-item .title').text(order_item.quantity+" "+order_item.description)
    $order_items.empty() 
    $order_items.append( 
      $.map(order_item.ids, function(item_id) {
        return "<input type='hidden' name='order_item_ids[]' value='"+item_id+"'></input>"
      }).join('')   
    )
    // app.loadDynamicPage('#show-queued-order-item', 'queued_order_item', {
    //   serverControllerName: 'queued_order_items',
    //   serverObjectName: 'order_item',
    //   getTitle: function(order_item) {return order_item.description}
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
    app.interval_id = window.setInterval(app.loadShowCustomerQueue, 5000);
  },
  onExit: function() {
    window.clearInterval(app.interval_id)
  }
});
app.addPage('show', 'queued-order', {onEntry: app.loadShowQueuedOrder});
app.addPage('show', 'queued-order-item', {onEntry: app.loadShowQueuedOrderItem});
