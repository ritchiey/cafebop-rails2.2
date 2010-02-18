var jQT = $.jQTouch({ 
    cacheGetRequests: false,
    icon: '/images/icon.png',
    // formSelector: 'form.ajax',
    statusBar: 'black-translucent',
    preloadImages: [
    ]
});                               



var app = {
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
  
  listLink: function(label, href, target_id) {
    return "<li class='arrow'><a class='to-shop' href='#' target-id='"+target_id+"'>"+label+"</a></li>";
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
          return app.listLink(shop.name, "#show-shop", shop.id);
        });
        $shopList.empty();
        $shopList.append(shopListEntries.join(''));
      })
    } else {
      alert('Not logged in so clearing home!');
      app.clearHomePage();
    }
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


// Manage link events
$('a.to-shop').tap(function(e) {
  app.shop_id = $(this).attr('target-id');
  jQT.goTo('#show-shop', 'slide');
  return false;
});


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

  $('#home').bind('pageAnimationEnd', function(e, info) {
     if (info.direction == 'out') return;
     app.loadHome();
  });
  
  app.loadHome();
  

});
