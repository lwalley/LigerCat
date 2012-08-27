var Ligercat = {
	version: "2.1"
};

$(function(){
	
	
	(function($withSidebar){
		if($withSidebar.length > 0){
			Ligercat.Tabs = $withSidebar.find('#sidebar').tabs();
			Ligercat.KeywordCloud.init($withSidebar);
			Ligercat.SelectionPanel.init($withSidebar);
			Ligercat.Toolbar.init($withSidebar);
			Ligercat.PubmedCount.init($withSidebar);
		}
	})($('.with_sidebar'))
	
});