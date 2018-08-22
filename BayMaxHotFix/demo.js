require('SVProgressHUD')

defineClass('ViewController', {
  haha: function() {
    require('SVProgressHUD').showSuccessWithStatus('hello patch');
  }
})
