var Ligercat=Ligercat||{};

Ligercat.Toolbar = new Class({
  Implements:Options,
  options:{
    class_name:'toolbar'
  },
  
  initialize:function(dom_id, toolbar_items, options) {
    this.setOptions(options);
    this._injectHTML(dom_id);
    this.element = $(dom_id);
    this._buildToolbar(toolbar_items);
    this.enable();
  },
  
  enable:function(){
    this.element.removeClass('disabled');
    this.enabled = true;
  },
  
  disable:function(){
    this.element.addClass('disabled');
    this.enabled = false;
  },
  
  _injectHTML:function(dom_id){
    document.writeln('<ul id="'+dom_id+'" class="'+this.options.class_name+'"></ul>');
  },
  
  _buildToolbar:function(toolbar_items){
    toolbar_items.each(function(i){
      var item = this._buildToolbarItem(i);
      item.inject(this.element, 'bottom');
    }.bind(this));
  },
  
  _buildToolbarItem:function(item) {
    var text     = item.text;
    var klass    = item['class'] || text.toLowerCase().replace(/\W/g, '_');
    var callback = item.callback;
    var href     = item.href || '#';
    
    var li    = new Element('li', {'class':klass});
    var link  = new Element('a',  {'href':href, 'html':'<span>'+text+'</span>', 'events':{'click': function(){ if(this.enabled && callback){callback(); return false;} }.bind(this) }});
    
    link.inject(li, 'bottom');
    
    return li;
  }
});