var jQT = $.jQTouch({
    icon: '/images/icon.png',
    formSelector: 'form.ajax',
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
  
  submitForm: function(form, onComplete) {
    $.ajax({
     type: form.attr('method'),
     url: form.attr('action'),
     data:form.serialize(),
     complete: onComplete
    });
  },
  
  updateFormControls: function() {
    if (user != null && user.length > 0) {
      $('#login-button').hide();
      $('#logout-button').show();
    } else {
      $('#login-button').show();
      $('#logout-button').hide();
    }
  } 
};         


$(function() { // on page ready
  
  // $.ajaxSetup({
  //     beforeSend: function (xhr) {
  //             xhr.setRequestHeader("Accept", "text/javascript, text/html, application/xml, text/xml, */*");
  //     }
  // });
  // 
  $('a.login').tap(function(e) { 
    var $form = $(this).closest("form");
    return app.login($form);   
  });

  $('form#login').submit(function(e) {
    var $form = $(this);
    return app.login($form)
  });  
  
  $('#logout-button').tap(function(e) {
    var $form = $('form#logout');
    app.submitForm($form, function(req) {
      user = null;
      app.updateFormControls();
    });
  });
  
  app.updateFormControls();  

  $('#show-queue').bind('pageAnimationEnd', function(e, info) {
    // alert('Going '+info.direction);
    if (info.direction == 'out') return;
    var order_id = 1; // TODO: pick up this value from the page
    app.getContent('/orders/'+order_id+'/order_items', function(data) {
      alert('Got content!!');
      var $ul = $('ul#orders');
      $ul.append('<li>Something</li>');
      jQuery.each(data, function() {
        $ul.append('<li>'+this.name+'</li>');
      });
    });
  });

});
