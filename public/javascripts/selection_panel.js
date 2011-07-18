// This is some shit that I shouldn't have to deal with
Element.implement({
  isVisible: function(){
    return new Hash(this.getCoordinates()).every(function(v){ return v !== 0; });
  }
});

var Ligercat=Ligercat||{};

Ligercat.SelectionPanelItem = new Class({
  Implements:Events,
  
  initialize:function(trigger_element, type) {
    this.trigger_element = trigger_element;
    this.type = type || null;
    
    this.list_element = this._buildListElement();
    this._selectTrigger();
  },
  
  remove:function(options){
    options=options||{suppress_events:false};
    
    if(!options.suppress_events){
      this.fireEvent('remove', this);
    }
    this._deselectTrigger();
    this.slide('out_then_die');
  },
  
  slide:function(direction){
    if(direction == 'in') {
      this.list_element.set('slide', {duration:'short'});
      this.list_element.slide('hide').slide('in');
    }
    if(direction == 'out_then_die'){
      this.list_element.set('slide', {onComplete:function(e){e.slide('hide').get('slide').wrapper.destroy();}, duration:'short'});
      this.list_element.slide('out');
    }
  },
  
  identify:function(){
    return Ligercat.SelectionPanelItem.keyFromTrigger(this.trigger_element);
  },
  
  _buildListElement:function(){
    var item_li = new Element('li',{ 'text': ' ' + this._getTriggerText() });
    var remove_button = new Element('a', { 
      'href':'#',
      'html':'<img src="/images/trash.gif" alt="Trash"/>',
      'events':{ 'click': function(){this.remove(); return false;}.bind(this) }
    });
    remove_button.inject(item_li, 'top');
    return item_li;
  },
    
  _selectTrigger: function(){
    this.trigger_element.addClass('selected');
  },
  
  _deselectTrigger:function(){
    this.trigger_element.removeClass('selected');
  }, 
  
  _getTriggerText:function(){
    return this.trigger_element.get('text');
  }
});
Ligercat.SelectionPanelItem.keyFromTrigger = function(trigger_element){
  return trigger_element.get('text');
};



Ligercat.SelectionPanel = new Class({
  Implements: [Options,Events],
  PanelItemClass:Ligercat.SelectionPanelItem,
  
  options: {
    no_terms_text: 'Select terms from the cloud to search PubMed',
    no_terms_class: 'no_terms_selected'
  },
  
  initialize:function(html_id, term_selector, options){
    this.setOptions(options);
    this._injectHTML(html_id);
    this.element = $(html_id);
    this.selections = new Hash();
    this.addEvent('empty', this._showHint.bind(this));
    this.addEvent('add',   this._hideHint.bind(this));
    window.addEvent('domready', this._addHandlerToTerms.bind(this, term_selector));
  },
  
  toggle:function(trigger_element) {
    var key = this.PanelItemClass.keyFromTrigger(trigger_element);
    if(this.selections.has(key)){
      this.remove(trigger_element);
    } else {
      this.add(trigger_element);
    }
  },
  
  add:function(trigger_element, options){
    options=$merge({suppress_events:false}, options);
    if(!options.suppress_events){this.fireEvent('beforeAdd');}
    
    var panel_item = new this.PanelItemClass(trigger_element);
    var key = this.PanelItemClass.keyFromTrigger(trigger_element);

    this._appendSelectionPanelItem(panel_item);
    this.selections.set(key,panel_item);
    
    panel_item.addEvent('remove', this._remove.bind(this)); // Mega-Crucial
    
    if(!options.suppress_events){ this.fireEvent('add', panel_item); }
  },
  
  remove:function(trigger_element){
    var key = this.PanelItemClass.keyFromTrigger(trigger_element);
    var panel_item = this.selections.get(key);
    if(panel_item) {
      panel_item.remove();
      return true;
    } else { return false; }
  },
  
  _remove:function(panel_item){
    var key = panel_item.identify();    
    this.selections.erase(key);
    
    if(this.selections.getLength() === 0) {
      this.fireEvent('empty');
    }
    
    this.fireEvent('remove', panel_item);
  },
  
  removeAll:function(){
    this.selections.getValues().each(function(panel_item){
      panel_item.remove({suppress_events:true});
    }.bind(this));
    
    this.selections.empty();
    
    this.fireEvent('removeAll');
    this.fireEvent('empty');
  },
  
  _injectHTML:function(dom_id){
    document.writeln('<ol id="'+dom_id+'"><li class="'+this.options.no_terms_class+'">'+this.options.no_terms_text+'</li></ol>');
  },
  
  _showHint:function(){
    var hint = this.element.getElement('.'+this.options.no_terms_class);
    if(!hint) {
      hint = new Element('li', {'class':this.options.no_terms_class, 'text': this.options.no_terms_text});
      hint.inject(this.element, 'top');
    }
  },
  
  _hideHint:function(){
    var hint = this.element.getElement('.'+this.options.no_terms_class);
    if(hint){ hint.destroy(); }
  },
  
  _clickHandler:function(evt){
    this.toggle(evt.target);
    return false;
  },
  
  _addHandlerToTerms:function(selector){
    if(selector){
      $$(selector).each(function(e){ e.addEvent('click', this._clickHandler.bind(this) ); }.bind(this));
    }
  },
  
  _appendSelectionPanelItem:function(panel_item){
    panel_item.list_element.inject(this.element);
		if(this.element.isVisible()) {
    	panel_item.slide('in');
		}
  }
});
