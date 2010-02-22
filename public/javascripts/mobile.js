var jQT = $.jQTouch({ 
    cacheGetRequests: false,
    icon: '/images/icon.png',
    // formSelector: 'form.ajax',
    statusBar: 'black-translucent',
    preloadImages: [
    ]
});                               


var app = { 
  
  underscore: function(src) {
    return src.replace(/-/g, "_" );
  },
  
  login: function($form) {
    $.ajax({
     type: $form.attr('method'),
     url: $form.attr('action'),
     data:$form.serialize(),
     complete:function(req) {
        if (req.status == 200 && req.responseText != 'false') { 
         user = req.responseText;
         app.updateFormControls();
         jQT.goBack();
        } else {
          alert("There was an error logging in. Try again.");
        }
     }
    });
    return false; 
  },
  
  listLink: function(label, classes, target_id) {
    return "<li class='arrow'><a class='"+classes+"' href='#' target-id='"+target_id+"'>"+label+"</a></li>";
  },
  
  getContent: function(url, success) {
    $.ajax({
      type: 'GET',
      success: success,
      url: url, 
      dataType: 'json'
    });
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
 
  
  // loadDynamicPage: function(options) {
  //   var config = jQuery.merge({}, {
  //     requireLogin: true,
  //     app: app,
  //     titleSelector: this.pageSelector + ' .title'
  //   }, options);
  //   
  //   $(config.titleSelector).text('Loading...');
  //   if (app.isLoggedIn()) {
  //     app.getContent("/customer_queues/"+app.customer_queue_id+"/", function(data) {
  //       var queue = data.customer_queue
  //       $('#customer-queue-name').text(queue.name);
  //       var orderLinks = jQuery.map(queue.orders, function(order) {
  //         return app.listLink(order.name, 'to-show-queued-order', order.id);
  //       });
  //       var $orderList = $('#order-list');
  //       $orderList.empty();
  //       $orderList.append(orderLinks.join(''));
  //     });
  //   }
  //   
  // },
  
  loadShowCustomerQueue: function() {
    $('#customer-queue-name').text('Loading...');
    if (app.isLoggedIn()) {
      app.getContent("/customer_queues/"+app.customer_queue_id+"/", function(data) {
        var queue = data.customer_queue
        $('#customer-queue-name').text(queue.name);
        var orderLinks = jQuery.map(queue.orders, function(order) {
          return app.listLink(order.name, 'to-show-queued-order', order.id);
        });
        var $orderList = $('#order-list');
        $orderList.empty();
        $orderList.append(orderLinks.join(''));
      });
    }
  },   

  rubify: function(str) {
    return(str.replace(/-/g, '_'));
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
        // Set page title
        $(titleSelector).text(getTitle(obj));
        
        // Populate each list on the page
        $(pageSelector + ' .item-list').each(function(index, itemList) {
          var subCollectionName = app.rubify($(itemList).attr('id'));
          if (subCollectionName == null) return; // todo throw exception here
          if (obj[subCollectionName] == null)  return; // todo throw exception
          // alert('obj[subCollectionName] = '+obj[subCollectionName].length);
          var entries = jQuery.map(obj[subCollectionName], function(subObj) {
            return entryToHtml(subObj, subCollectionName);
          });
          $(itemList).empty();
          $(itemList).append(entries.join(''));
        });
      });
    }
  },   

  loadShowQueuedOrder: function() {
    app.loadDynamicPage('#show-queued-order', 'queued_order', {
      serverObjectName: 'order',
      serverControllerName: 'queued_orders',
      getTitle: function(order) {return order.effective_name},
      entryToHtml: function(order_item, list_name) {
        return app.listLink(order_item.quantity+' '+order_item.description, 'to-show-queued-order-item arrow', order_item.id)
      }
    });
  },

  loadShowQueuedOrderItem: function() {
    $('#order-item-name').text('Loading...');
    if (app.isLoggedIn()) {
      app.getContent("/orders_items/"+app.queued_order_item_id+"/", function(data) {
        var order = data.order
        $('#order-name').text(order.name);
        var orderItemLinks = jQuery.map(order.order_items, function(order_item) {
          return app.listLink(order_item.description, 'to-show-queued-order-item', order_item.id);
        });
        var $orderItemList = $('#order-item-list');
        $orderList.empty();
        $orderList.append(orderLinks.join(''));
      });
    }
  },
  
  bindPage: function(pageSelector, onLoad) {
    $(pageSelector).bind('pageAnimationEnd', function(e, info) {
       if (info.direction == 'out') return;
       onLoad();
    });
  },
 
  bindLink: function(linkSelector, pageSelector, beforeRender) {
    $(linkSelector).tap(function(e) {
      beforeRender(e);
      jQT.goTo(pageSelector, 'slide');
      return false;
    });
  },
  
  // Register a static page ('#verb-noun') that may load dynamic data
  // when displayed. Also hook the tap event on any a.to-verb-noun links
  // and set an variable app.noun_id to be the value taken from the 'target-id'
  // attribute of the link.
  addPage: function(verb, noun, onLoad) {  
    var pageSelector = '#'+verb+'-'+noun
    $(function() {app.bindPage(pageSelector, onLoad)});
    app.bindLink('a.to-'+verb+'-'+noun, pageSelector, function(e) {
      app[app.underscore(noun)+'_id'] = $(e.target).attr('target-id');
    });
  },

  
  submitForm: function(form, onComplete) {
    $.ajax({
     type: form.attr('method'),
     url: form.attr('action'),
     data:form.serialize(),
     complete: onComplete
    });
  },
  
  clearHomePage: function() {
    // TODO: Remove all items from the home page
    alert('clearing home page');
  },
  
  isLoggedIn: function() {
    return (user != null && user.length > 0);
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

$(function() { // on page ready

  $('a.login').tap(function(e) { 
    var $form = $(this).closest("form");
    return app.login($form);   
  });

  $('form#login').submit(function(e) {
    var $form = $(this);
    return app.login($form);
  });  
  
  $('#logout-button').tap(function(e) {
    var $form = $('form#logout');
    app.submitForm($form, function(req) {
      user = null;
      app.updateFormControls();
      app.clearHomePage(); 
      jQT.goBack('#home');
    });
  });
  
  app.updateFormControls();  


  // Setup load events for each page
  app.bindPage('#home', app.loadHome);

  // Dynamically populate the homepage
  app.loadHome();
});

app.addPage('show', 'shop', app.loadShowShop); 
app.addPage('show', 'customer-queue', app.loadShowCustomerQueue);
app.addPage('show', 'queued-order', app.loadShowQueuedOrder);
app.addPage('show', 'queued-order-item', function() {
  app.loadDynamicPage('#show-queued-order-item', 'queued_order_item', {
    serverObjectName: 'order_item', 
    getTitle: function(order_item) {return order_item.description}
  })
});
