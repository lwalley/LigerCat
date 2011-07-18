var Ligercat=Ligercat||{};

Ligercat.MeshAndTextSelectionPanelItem = new Class({
  Extends: Ligercat.SelectionPanelItem,
  
  initialize:function(trigger_object){
    this.keyword = trigger_object.element.get('text');
    this.parent(trigger_object, trigger_object.type);
  },
  identify:function(){
    return Ligercat.MeshAndTextSelectionPanelItem.keyFromTrigger(this.trigger_element);
  },  
  _selectTrigger: function(){
    this.trigger_element.element.addClass('selected');
  },
  _deselectTrigger:function(){
    this.trigger_element.element.removeClass('selected');
  }, 
  _getTriggerText:function(){
    var type = this.trigger_element.type;
    var suffix;
    if (type == 'mesh') { suffix = 'mh'; }
    else                { suffix = 'tw'; }
    
    return this.keyword + ' ['+suffix+']';
  }
});

Ligercat.MeshAndTextSelectionPanelItem.keyFromTrigger = function(trigger_object){
  return trigger_object.type + '##' + trigger_object.element.get('text');
};


Ligercat.MeshAndTextSelectionPanel = new Class({
  Extends:Ligercat.MeshSelectionPanel,
  PanelItemClass:Ligercat.MeshAndTextSelectionPanelItem,
  
  initialize: function(html_id, mesh_term_selector, text_term_selector, options){
    this.pubmed_search_within_journals = new Ligercat.MedlineSearch(this.displayPubmedCountForJustTheseJournals.bind(this));

    window.addEvent('domready', this._addHandlerToTextTerms.bind(this, text_term_selector));

    this.parent(html_id, mesh_term_selector, options);
  },
  
  fetchPubmedCount:function(){
    var keywords = this._meshAndTextSelections();
    this.pubmed_count_all.addClass('loading');
    this.pubmed_search.getArticleCount(keywords.mesh, keywords.text);
    
    this.pubmed_count_journals.addClass('loading');
    this.pubmed_search_within_journals.getArticleCount(keywords.mesh, keywords.text);
  },
  
  displayPubmedCount:function(count, direct_url){
    this.pubmed_count_all.removeClass('loading');
    this.pubmed_count_all.set('text', count + ' articles in PubMed');
  },
  
  displayPubmedCountForJustTheseJournals:function(count, direct_url){
    this.pubmed_count_journals.removeClass('loading');
    this.pubmed_count_journals.set('html', count + ' articles in <a href=\''+direct_url+'\' target="_blank" class="external_link">these journals</a>');
  },
  
  updateDirectPubmedLink:function(options){
    options        = options || {};
    var keywords   = this._meshAndTextSelections();
    options.url    = options.url || this.pubmed_search.directPubmedLink(keywords.mesh, keywords.text);
    options.target = options.target || '_blank';
    this.toolbar.element.getElement('.go_to_pubmed a').set({'href':options.url, 'target':options.target});
  },
  
  _showPubmedCount:function(){
    this.pubmed_count_wrapper.slide('in');
  },
  
  _hidePubmedCount:function(){
    this.pubmed_count_wrapper.slide('out');
  },
  
  _injectPubmedCountHTML:function(dom_id){
    document.writeln('<div id="'+dom_id+'_pubmed_count_wrapper" class="pubmed_count"><div id="'+dom_id+'_pubmed_all" class="loading">Loading...</div><div id="'+dom_id+'_pubmed_journals" class="loading">Loading...</div></div>');
    this.pubmed_count_wrapper = $(dom_id + '_pubmed_count_wrapper');
    this.pubmed_count_wrapper.slide('hide');
    this.pubmed_count_all = $(dom_id + '_pubmed_all');
    this.pubmed_count_journals = $(dom_id + '_pubmed_journals');
  },
  
  // This method splits the selections into two arrays, one
  // full of Mesh terms and the other full of Text terms
  _meshAndTextSelections:function(){
    var mesh = [];
    var text = [];
    var panel_items = this.selections.getValues();
    for(var i=0; i<panel_items.length; i++){
      var item = panel_items[i];
      if( item.type == 'mesh' ) { mesh.push(item.keyword); }
      else                      { text.push(item.keyword); }
    }
    return {mesh:mesh, text:text};
  },
  
  // This should be named _addHandlerToMeshTerms, but I kept it
  // this way to it'd be called by the superclass
  _addHandlerToTerms:function(selector) {
    this._addHandler(selector, 'mesh');
  },
  
  _addHandlerToTextTerms:function(selector) {
    this._addHandler(selector, 'text');
  },
  
  _addHandler:function(selector, type){
    if(selector){
      $$(selector).each(function(e){
        e.addEvent('click', function(evt){
          this.toggle( {type:type, element:evt.target} );
          return false;
        }.bind(this));
      }.bind(this));
    }
  }
});