//= require ligercat
//= require selected_terms
//= require pubmed_query_builder

Ligercat.PubmedCount = {
	config: {
		baseURL : '', // TODO it'd be nice to use ERB to insert pubmed_count_url
	},
	
	init:function($withSidebar){
		var $element = $withSidebar.find('#selected_terms_pubmed_count');
		
		$element.hide();
		
		Ligercat.SelectedTerms.on('empty', function(){
			$element.slideUp('fast');
		});
		
		Ligercat.SelectedTerms.on('change', function(e, terms){
			var pubmedQuery = Ligercat.PubmedQueryBuilder.build(terms),
  			    url = Ligercat.PubmedCount.config.baseURL;
			
			$element.addClass('loading').text('Loading...').slideDown('fast');
			
			$.get(url, {term: pubmedQuery}, function(data){
				$element.text(data + ' articles in PubMed with all of these terms').removeClass('loading');
			});
			
		});
		
	}
};