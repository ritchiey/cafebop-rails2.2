var jQT = $.jQTouch({
    icon: '/images/icon.png',
       formSelector: '.form',
    statusBar: 'black-translucent',
    preloadImages: [
    ]
});                               

$('a.login').tap(function(e) { 
  alert("hi");
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
     dataType:'json',
     data:$form.serialize(),
     complete:function(req) {
        if (req.status == 200 || req.status == 304) {
         jQT.goBack();
        } else {
          alert("There was an error logging in. Try again.");
        }
     }
    });
    return false; 
  }
};         