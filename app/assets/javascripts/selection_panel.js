//= require selected_terms

Ligercat.SelectionPanel = {
	init: function($withSidebar) {
		var $element = $withSidebar.find('#selected_terms');
		var item_template = _.template('<li id="selectedTerm_<%= id %>" class="selected_term"><img src="/assets/trash.gif" alt="Remove" /> <%= name %></li>');
		var $empty_item = $('<li class="no_terms_selected">Select terms from the cloud to search PubMed</li>');
		
		
		$empty_item.appendTo($element);
		
		Ligercat.SelectedTerms.on('add', function(e, term) {
			var $new_item = $(item_template(term));
			
			$element.find('li.no_terms_selected').remove();
			
			$new_item.find('img').click(function(){ Ligercat.SelectedTerms.remove(term.id); });
			$new_item.appendTo($element).hide().slideDown('fast');
			
			Ligercat.Tabs.tabs('select', '#selected_terms_panel');
		});
		
		Ligercat.SelectedTerms.on('remove', function(e, term) {
			$element.find('#selectedTerm_'+term.id).slideUp('fast', function(e){
				$(this).remove();	
			});
		});
		
		Ligercat.SelectedTerms.on('empty', function(){
			$element.find('li.selected_term').slideUp('fast', function(){ $(this).remove(); });
			
			$empty_item.appendTo($element);
		});
	}
};