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
          return app.listLink(queue.name, 'to-customer-queue', queue.id);
        });
        var $queueList = $('#customer-queue-list');
        $queueList.empty();
        $queueList.append(customerQueueListEntries);
      });
    }
  },
 
  
  // loadShowCustomerQueue: function() {
  //   $('#queue-name').text('Loading...');
  //   if (app.isLoggedIn()) {
  //     app.getContent("/customer_queues/"+app.customer_queue_id+"/", function(data) {
  //       var shop = data.shop;
  //       $('#shop-name').text(shop.name);
  //       var customerQueueListEntries = jQuery.map(shop.customer_queues, function(queue) {
  //         return app.listLink(queue.name, 'to-customer-queue', queue.id);
  //       });
  //       var $queueList = $('#customer-queue-list');
  //       $queueList.empty();
  //       $queueList.append(customerQueueListEntries);
  //     });
  //   }
  // },  

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
  // app.bindPage('#show-shop', app.loadShowShop);
  app.bindPage('#show-customer-queue', app.loadShowCustomerQueue);

  // Setup tap events for various links
  // app.bindLink('a.to-shop', '#show-shop', function(e) {app.shopId = $(e.target).attr('target-id')});
  app.bindLink('a.to-customer-queue', '#show-customer-queue', function(e) {app.shopId = $(e.target).attr('target-id')});
  
  
  app.loadHome();
  

});

app.addPage('show', 'shop', app.loadShowShop); 
app.addPage('show', 'customer-queue', app.loadShowCustomerQueue);
