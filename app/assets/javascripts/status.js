//= require ligercat

Ligercat.Status = {
  config: {
    interval: 2000,
    url: document.location.href + ".json"
  },
  
  init: function($element) {
    
    
    $element.find('.current').prevAll().addClass('done');
    
    var i = setInterval(function() {
      
      $.get(Ligercat.Status.config.url, function(status){

        if(status.done) {
          $element.find('li').removeClass('current').addClass('done');
          
          // Refresh the page, hit the server to get redirected to final url
          setTimeout(function(){ location.reload(true); }, 500);
        } else if (status.error){
          var $parent = $element.parent();          
          $parent.empty().append($(status.template));
          
          clearInterval(i);
        } else {
          var $currentState = $element.find("#state_" + status.code);
          
          $currentState.addClass('current');
          $currentState.prevAll().removeClass('current').addClass('done');
        }
      }, 'json');
      
    }, Ligercat.Status.config.interval);
  
  }
};