//= require ligercat

Ligercat.Status = {
	config: {
		interval: 2000,
		url: document.location.href + ".js"
	},
	
	init: function($element) {
		var i = setInterval(function() {
			
			$.get(Ligercat.Status.config.url, function(responseText){

				if(responseText.match(/done/)) {
					location.reload(true); // Refresh the page, hit the server to get redirected to final url
				} else {
					var oldText = $element.text();
					$element.text(responseText)
					
					if(oldText != responseText) $element.effect("highlight", {}, 1500);
				}
			}, 'html');
			
		}, Ligercat.Status.config.interval);
	
	}
};