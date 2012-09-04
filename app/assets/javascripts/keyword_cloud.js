//= require selected_terms

Ligercat.KeywordCloud = {
  init: function($withSidebar) {
    var $element = $('.keyword_cloud');
    
    $element.find('li a').click(function(e){
      var $parent = $(this).parent(),
        mesh_id = $parent.data('mesh-id'),
        mesh_name = $parent.data('mesh-name');
      
      Ligercat.SelectedTerms.toggle(mesh_id, mesh_name);
      
      e.preventDefault();
    });
    
    Ligercat.SelectedTerms.on('add', function(e, term) {
      $element.find('#mesh_'+term.id).addClass('selected'); 
    });
    
    Ligercat.SelectedTerms.on('remove', function(e, term) {
      $element.find('#mesh_'+term.id).removeClass('selected');
    });
    
    Ligercat.SelectedTerms.on('empty', function(){
      $element.find('li').removeClass('selected');
    });
  }
};