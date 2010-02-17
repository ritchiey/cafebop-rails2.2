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
  
  getContent: function(url, success) {
    $.ajax({
      type: 'GET',
      success: success,
      url: url,
      // beforeSend: function(xhr) {
      //   xhr.setRequestHeader("Accept", "text/javascript");
      //   alert(xhr);
      //   return true;
      // },  
      dataType: 'json'
    });
  },
  
  loadHome: function() {
    if (app.isLoggedIn()) {
      app.getContent("/", function(data) {
        alert('got data');
        jQuery.each(data.work_contracts, function() {
          var wc = this.work_contract;
          alert('wc: ' + wc.role);
        });
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

  // $('#show-queue').bind('pageAnimationEnd', function(e, info) {
  //   // alert('Going '+info.direction);
  //   if (info.direction == 'out') return;
  //   var order_id = 1; // TODO: pick up this value from the page
  //   app.getContent('/orders/'+order_id+'/order_items', function(data) {
  //     alert('Got content!!');
  //     var $ul = $('ul#orders');
  //     $ul.append('<li>Something</li>');
  //     jQuery.each(data, function() {
  //       $ul.append('<li>'+this.name+'</li>');
  //     });
  //   });
  // }); 


});
