/*
 * Schenktabs 1.0
 */
Tabs = new Class({
  Implements:[Options, Events, Chain],
  options: {start_index:0},
  before_hide:[],
  after_show:[],
  
  initialize: function(tab_selector, content_selector, options){
    this.setOptions(options);
    this.tabs=$$(tab_selector+" li");
    this.tabs_a=$$(tab_selector+" a");
    this.contents=$$(content_selector);
    this.showTab(this.options.start_index);
    this.addHanderToTabs();
    return this;
  },
  
  showTab: function(tab_index){
    if(tab_index != this.current_tab) {
      this.hideAll();
      
      this.chain(
        function(){ this.contents[tab_index].setStyle('display', 'block'); this.callChain(); },
        function(){ this.fireEvent('onShowTab', [tab_index, this.current_tab]);
                    this.current_tab = tab_index;
                    this.activateTab(tab_index);
                    this.callChain(); }
      );
      
      if(this.after_show[tab_index]){
        this.chain(this.after_show[tab_index]);
      }

      this.callChain();
    }
    return this;
  },
  
  hideAll:function(){
    if(this.before_hide[this.current_tab]){
      this.chain(this.before_hide[this.current_tab]);
    }
    
    this.contents.each(function(content_elem) {
      this.chain(function(){ content_elem.setStyle('display', 'none'); this.callChain(); });
    },this);
  },
  
  activateTab: function(tab_index){
    this.tabs.removeClass('active');
    this.tabs_a.removeClass('active');
    this.tabs[tab_index].addClass('active');
    this.tabs_a[tab_index].addClass('active');
  },
  
  addHanderToTabs: function(){
    this.tabs_a.each(function(tab_elem, i){
      tab_elem.addEvent('click', function(event){
        event.stop();
        this.showTab(i);
      }.bind(this));
    }, this);
  }
});