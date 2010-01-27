var jQT = $.jQTouch({
    icon: '/images/icon.png',
       formSelector: '.form',
    statusBar: 'black-translucent',
    preloadImages: [
    ]
});                               

$('a.login').tap(function(e) { 
  var $form = $(this).closest("form");
  return app.login($form);   
});

$('form#login').submit(function(e) {
  var $form = $(this);
  return app.login($form)
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
  
  $('#logout-button').tap(function(e) {
    var $form = $('form#logout');
    app.submitForm($form, function(req) {
      user = null;
      app.updateFormControls();
    });
  });
  
  app.updateFormControls();  
  
});