//= require ligercat
//= require selected_terms
//= require pubmed_query_builder

Ligercat.Toolbar = {
	config: {
		baseURL : 'http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=Search&term=',
	},
	
	init:function($withSidebar){
		var $element = Ligercat.Toolbar.$element = $withSidebar.find('#selected_terms_toolbar'),
		    $removeAll = $element.find('.remove_all'),
		    $goToPubmed = $element.find('.go_to_pubmed a');
		
		Ligercat.Toolbar.prevent_clicks = function(e){ e.preventDefault(); };
			
		
		Ligercat.Toolbar.disable();
		
		$removeAll.click(function(e){
				Ligercat.SelectedTerms.empty();
				e.preventDefault();
		})
		
		Ligercat.SelectedTerms.on('empty', function(){
			Ligercat.Toolbar.disable();
		});
		
		Ligercat.SelectedTerms.on('change', function(e, terms){
			var pubmedQuery = Ligercat.PubmedQueryBuilder.build(terms),
			    pubmedLink = Ligercat.Toolbar.config.baseURL + encodeURI(pubmedQuery);
				
			Ligercat.Toolbar.enable();
			
			
			$goToPubmed.attr('href', pubmedLink);
		});
		
	},
	
	disable: function(){
		Ligercat.Toolbar.$element.addClass('disabled');
		Ligercat.Toolbar.$element.find('a').on('click', Ligercat.Toolbar.prevent_clicks);
	},
	
	enable: function(){
		Ligercat.Toolbar.$element.removeClass('disabled');
		Ligercat.Toolbar.$element.find('a').off('click', Ligercat.Toolbar.prevent_clicks);
	}
		
	
};