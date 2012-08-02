var Ligercat=Ligercat||{};

Ligercat.MeshSelectionPanel = new Class({
  Extends:Ligercat.SelectionPanel,
  
  initialize:function(html_id, term_selector, options){
    var optional_scope = '';
    if(options && options.optional_scope) { optional_scope = options.optional_scope; } // TODO there must be a better way to do this.
    this.pubmed_search = new Ligercat.MedlineSearch(this.displayPubmedCount.bind(this), optional_scope);
    
    this.addEvents({'add':    this.onContentUpdate.bind(this),
                    'remove': this.onContentUpdate.bind(this),
                    'empty':  this.onEmpty.bind(this) });
                    
    this.toolbar = new Ligercat.Toolbar(html_id + '_toolbar', [{text:'Remove All', callback:this.removeAll.bind(this)}, {text:'Go to Pubmed'}]);
    this.toolbar.disable();
    
    this._injectPubmedCountHTML(html_id);
    this.parent(html_id, term_selector, options);
  },
  
  fetchPubmedCount:function(){
    this.pubmed_count_element.addClass('loading');
    this.pubmed_search.getArticleCount(this.selections.getKeys(),[]);
  },
  
  updateDirectPubmedLink:function(options){
    options        = options || {};
    options.url    = options.url || this.pubmed_search.directPubmedLink(this.selections.getKeys(),[]);
    options.target = options.target || '_blank';
    this.toolbar.element.getElement('.go_to_pubmed a').set({'href':options.url, 'target':options.target});
  },
  
  displayPubmedCount:function(count){
    this.pubmed_count_element.removeClass('loading');
    this.pubmed_count_element.set('text', count + ' articles in PubMed with all of these terms');
  },

  onContentUpdate:function(){
    if(this.selections.getLength() > 0) {
      this.toolbar.enable();
      this._showPubmedCount();
      this.updateDirectPubmedLink();
      this.fetchPubmedCount();
    }
  },
  
  onEmpty:function(){
    this.toolbar.disable();
    this._hidePubmedCount();
    this.updateDirectPubmedLink({url:'#', target:'_self'});
  },
  
  _showPubmedCount:function(){
    this.pubmed_count_element.slide('in');
  },
  
  _hidePubmedCount:function(){
    this.pubmed_count_element.slide('out');
  },
  
  _injectPubmedCountHTML:function(dom_id){
    document.writeln('<div id="'+dom_id+'_pubmed_count" class="pubmed_count loading">Loading...</div>');
    this.pubmed_count_element = $(dom_id + '_pubmed_count');
    this.pubmed_count_element.slide('hide');
  }
});