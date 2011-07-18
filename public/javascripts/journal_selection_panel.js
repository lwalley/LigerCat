var Ligercat=Ligercat||{};

Ligercat.JournalSelectionPanelItem = new Class({
  Extends: Ligercat.SelectionPanelItem,
  identify:function(){
    return Ligercat.JournalSelectionPanelItem.keyFromTrigger(this.trigger_element);
  },  
  _selectTrigger: function(){
    if( $type(this.trigger_element ) == 'element' ) { this.trigger_element.checked = true; }
  },
  _deselectTrigger:function(){
    if( $type(this.trigger_element ) == 'element' ) { this.trigger_element.checked = false; }
  }, 
  _getTriggerText:function(){
    if( $type(this.trigger_element ) == 'element' ) {
      return this.trigger_element.getParent().getElement('a').get('text');
    } else {
      return this.trigger_element.title;
    }
  }
});
Ligercat.JournalSelectionPanelItem.keyFromTrigger = function(trigger_element){
  if($type(trigger_element) == 'element') {
    var id = trigger_element.get('id');
    return id.substring(id.lastIndexOf("_") + 1); // Takes "journal_12345", returns 12345
  } else {
    return trigger_element.id;
  }
};

Ligercat.JournalSelectionPanel = new Class({
  Extends: Ligercat.SelectionPanel,
  PanelItemClass:Ligercat.JournalSelectionPanelItem,
  
  options: {
    no_terms_text: 'Click the checkbox next to a journal to select it'
  },
  
  initialize:function(html_id, journal_selector, options){  
    this.addEvents({'add':    this.onContentUpdate.bind(this),
                    'remove': this.onContentUpdate.bind(this),
                    'empty':  this.onEmpty.bind(this)});

    // For AJAX posting to keep the journal selections around in a session
		this.use_ajax = true;

    this.addEvents({'add':      function(panel_item){ if(this.use_ajax){ this.postSelection(panel_item); } }.bind(this),
                    'remove':   function(panel_item){ if(this.use_ajax){ this.deleteSelection(panel_item); } }.bind(this),
                    'removeAll':function()          { if(this.use_ajax){ this.destroyAll(); }}.bind(this) });
                    
    this.toolbar = new Ligercat.Toolbar(html_id + '_toolbar', [{text:'Remove All', callback:this.removeAll.bind(this)}, {text:'Explore Selected'}]);
    this.toolbar.disable();
    
    this.postRequest        = new Request({url: '/selections/', method:'post', link:'chain'});
    this.destroyAllRequest  = new Request({url:'/selections/destroy_all', method:'delete'});
	  this.destroySomeRequest = new Request({url:'/selections/destroy_some', method:'delete'});
    
    this.parent(html_id, journal_selector, options);
  },
  
  preloadSelectionsFromSession: function(selections_from_sesh){
  	if (selections_from_sesh.length > 0) {
  	    for(var i=0; i< selections_from_sesh.length; i++){
  	      var trigger = selections_from_sesh[i];
  	      var checkbox = $('checkbox_' + trigger.id);
  	      if(checkbox) { trigger = checkbox; }
  	      this.add(trigger, {suppress_events:true});
  	    }
  		this._hideHint();
  	  this.onContentUpdate();
  	}
  },

  // // Holy crapstations this is such a royal hack
  addBatch:function(trigger_elements) {
   this.use_ajax = false;
   var journal_ids = [];
   trigger_elements.each(function(trigger_element){
     var key = this.PanelItemClass.keyFromTrigger(trigger_element);
     
     if( !this.selections.has(key) ){
       journal_ids.push(key);
       this.add(trigger_element);
     }
   }, this);
   
   if( journal_ids.length > 0) {
     this.postRequest.send('journal_id=' + journal_ids.join(';'));
   }
   
   this.use_ajax = true;
  },
  
	removeBatch:function(trigger_elements) {
		this.use_ajax = false;
		var journal_ids = [];
		trigger_elements.each(function(trigger_element){
			var key = this.PanelItemClass.keyFromTrigger(trigger_element);
			
			if( this.selections.has(key) ){
				journal_ids.push(key);
				this.remove(trigger_element);
			}
		}, this);
		
		if( journal_ids.length > 0) {
			this.destroySomeRequest.send('journal_id=' + journal_ids.join(';'));
		}
		
		this.use_ajax = true;
	},
  
  postSelection:function(panel_item){
    var journal_id = panel_item.identify();
    this.postRequest.send('journal_id=' + journal_id);
  },
  
  deleteSelection: function(panel_item){
    var journal_id = panel_item.identify();
    var req = new Request({url:'/selections/'+journal_id, method:'delete'});
    req.send();
  },
  
  destroyAll:function(){
    this.destroyAllRequest.send();
  },
  
  onContentUpdate:function(){
    if(this.selections.getLength() > 0) {
      this.toolbar.enable();
      this._updateExploreSelectedLink();
    }
  },
  
  onEmpty: function(){
    this.toolbar.disable();
    this._updateExploreSelectedLink({url:'#', target:'_self'});
  },
  
  _updateExploreSelectedLink:function(options){
    options        = options || {};
    options.url    = options.url || this.journalLink(this.selections.getKeys());
    options.target = options.target || '_self';
    this.toolbar.element.getElement('.explore_selected a').set({'href':options.url, 'target':options.target});
  },
  
  journalLink: function(journal_ids){
    return "/journals/" + journal_ids.join(";");
  },
  
  _clickHandler:function(evt){
    this.toggle(evt.target);
    return true;
  }
});