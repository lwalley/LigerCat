// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Journal = {
  _id_delimiter: ';', // This is the character used to join multiple journal ids together in the "Select All" feature. Make sure it's the same in SelectionsController#create
  
  checkbox_listener: function(event) {
    // Parse out the journal_id
    var element = event.element();
    var journal_id = Journal.Utilities.journalId(element);
    if (element.checked) {
      Journal.select(journal_id);
    } else {
      Journal.deselect(journal_id);
    }
  },
  
  set_up_select_all_links:function(all_journals_on_page_selected){
    if(all_journals_on_page_selected) {
      $('select_all').hide();
      $('deselect_all').show();
    } else {
      $('select_all').show();
      $('deselect_all').hide();
    }
  },
  
  select: function(journal_id) {
    var params = {journal_id: journal_id};
    Selections.show_spinner();
    new Ajax.Request('/selections/', {asynchronous:true,method:'post',parameters:params, onSuccess:function(transport){Journal.select_success(transport, journal_id)}.bind(this)});
  },
  
  select_all: function(){
    var journal_ids = Journal.journals_on_this_page();
    var params = {journal_id: journal_ids};
    $('select_all').down('.little_spinner').show();
    new Ajax.Request('/selections/', {asynchronous:true,method:'post',parameters:params, onSuccess:function(transport){$('select_all').hide();$('deselect_all').show();$('select_all').down('.little_spinner').hide();$('deselect_all').down('.little_spinner').hide();Journal.select_success(transport, journal_ids)}.bind(this)});
  },
  
  select_success: function(transport, journal_id){
    journal_id.split(Journal._id_delimiter).each(function(j_id){    // Sup with that? It's so we can use the same select_success callback from the "Select All" command, which joins a bunch of journal_ids together with semicolons (_id_delimiter)
      var checkbox = $('checkbox_' + j_id);
      Selections.add(j_id);
      checkbox.checked = true;
    });
    Selections.hide_spinner();
  },
  
  deselect: function(journal_id) {
    journal_id = Journal.Utilities.journalId(journal_id);
    var params = Authorization.parameters({});
    new Ajax.Request('/selections/' + journal_id, {asynchronous:true,method:'delete',parameters:params,onSuccess:Journal.deselect_success});
  },
  
  deselect_all:function(){
    var journal_ids = Journal.journals_on_this_page();
    $('deselect_all').down('.little_spinner').show();
    Selections.remove_some(journal_ids);
  },
  
  deselect_success: function(transport) {
    var url = transport.request.url;
    var id = url.substring(url.lastIndexOf('/')+1);
    Selections.remove(id);
    Journal.uncheck(id);
  },
  
  uncheck:function(nlm_id) {
    var checkbox = $('checkbox_' + nlm_id);
    if(checkbox) { checkbox.checked = false; }
    $('select_all').show();
    $('deselect_all').hide();
  },
  
  journals_on_this_page:function() {
    var journal_ids = '';
    var results = $$('ol.search_results').first().childElements();
    for(var i = 0; i < results.length; i++) {
      journal_ids += Journal.Utilities.journalId(results[i]);
      if(i < results.length - 1)
        journal_ids += Journal._id_delimiter;
    }
    return journal_ids;
  },
  
  Utilities: {
    /* Takes a string, int, or Element and returns the dom id of a journal element.
     * Useful for getting the DOM element when handling AJAX responses.
     */
    domId:function(journal_id) {
      journal_id = this.journalId(journal_id);
      return "journal_" + journal_id;
    },

    /* Takes a string, int, or Element and returns the journal id of a journal.
     * Useful for generating the URL for an AJAX request, if you
     * know a journal's DOM id
     */
    journalId:function(dom_id) {
      if(Object.isElement(dom_id))
        dom_id = dom_id.identify();
      if(Object.isString(dom_id))
        dom_id = dom_id.substring(dom_id.lastIndexOf("_") + 1); // parseInt(dom_id.substring(dom_id.lastIndexOf("_") + 1));
      return dom_id;
    }
  },
  
};

/* Returns the DOM Element for a journal 
 * Will accept a journal id, dom id, or Element (although that's
 * rather silly don't you think?)
 */
function $J(id) {
  if(Object.isElement(id))
    return id;
  
  id = Journal.Utilities.domId(id);
  return $(id);
}

Selections = {
  
  effect_queue: {position:'end', scope:'selections'},
  
  selection_tools_elem:function() {
    if(!this._selection_tools_elem) {
      this._selection_tools_elem = $('selection_tools');
    }
    return this._selection_tools_elem;
  },
  
  instructions_elem:function() {
    if(!this._instructions_elem) {
      this._instructions_elem = $('instructions');
    }
    return this._instructions_elem;
  },
  
  selection_list:function() {
    if(!this._selection_list_element) {
      this._selection_list_element = $('selection_list');
    }
    return this._selection_list_element;
  },
  
  selection_scrollpane:function() {
    if(!this._selection_scrollpane_element) {
      this._selection_scrollpane_element = $('selection_scrollpane');
    }
    return this._selection_scrollpane_element;
  },
  
  spinner:function() {
    if(!this._selection_spinner_element) {
      this._selection_spinner_element = $('selection_spinner');
    }
    return this._selection_spinner_element;
  },
  

  show:function() {
    if(!this.selection_tools_elem().visible() && !this._showing) {
      Effect.Fade(this.instructions_elem(),         {duration:0.3, queue:Selections.effect_queue});
      Effect.SlideDown(this.selection_tools_elem(), {duration:0.4, queue:Selections.effect_queue, afterFinish:function(){Selections.check_size();}});
      this._showing = true;
    }
  },
  
  hide:function() {
    if(this._showing == undefined){ this._showing = this.selection_tools_elem().visible(); }
    
    if(this.selection_tools_elem().visible() && this._showing) {
      Effect.SlideUp(this.selection_tools_elem(), {duration:0.3, queue:Selections.effect_queue});
      Effect.Appear(this.instructions_elem(),     {duration:0.5, queue:Selections.effect_queue});
      this._showing = false;
    }
  },
  
  show_spinner:function() {
    Selections.spinner().show();
  },
  
  hide_spinner:function() {
    Selections.spinner().hide();
  },
  
  check_size:function() {
    var selection_list = Selections.selection_list();
    var selection_scrollpane = Selections.selection_scrollpane();
    var max_height = 400;
    if (selection_list.getHeight() >= max_height) {
      if( !selection_scrollpane.hasClassName('really_long') ) { 
        selection_scrollpane.addClassName('really_long');
      }
    } else {
      if( selection_scrollpane.hasClassName('really_long') ) {
        selection_scrollpane.removeClassName('really_long');
      }
    }
  },
  
  add:function(journal_id) {
    if(! $("selection_" + journal_id) ) {
      var selections = Selections.selection_tools_elem();
      var selection_list = Selections.selection_list();
      var new_selection_elem = document.createElement('li');
      var trash_can_html = '<a href="#" onclick="Journal.deselect(Journal.Utilities.journalId(this.up())); return false;"><img alt="Trash" src="/images/trash.gif" /></a>';
      var text = $J(journal_id).down('a').text.truncate(40);
      Element.extend(new_selection_elem);
      new_selection_elem.id = "selection_" + journal_id;
      new_selection_elem.update(trash_can_html + ' ' + text);
      selection_list.insert(new_selection_elem, {position:'bottom'});
      Selections.refresh_compare_selected_url();
    
      if(selections.visible()) {
        new Effect.Highlight(new_selection_elem);
      } else {
        Selections.show();
      }
      
      Selections.check_size();
    }
  },
  
  remove:function(journal_id, options) {
    if(typeof options == 'undefined') { options = {animate: true}; }
    
    var selection_element = $('selection_'+journal_id);
    var selection_list = Selections.selection_list();
    
    options.animate = selection_list.childElements().length > 1;
    
    if(options.animate) {
      Effect.BlindUp(selection_element, {duration:0.2,afterFinish:function(obj){Selections._remove(journal_id)}.bind(this)});
    } else {
      Selections._remove(journal_id);
    }
    
    if(selection_list.childElements().length == 0) {
      Selections.hide();
    }
  },
  
  _remove:function(journal_id) {
    journal_id  = Journal.Utilities.journalId(journal_id);
    var selection_element = $('selection_'+journal_id);
    if(selection_element) {
    Journal.uncheck( journal_id );
      selection_element.remove();
      Selections.refresh_compare_selected_url();
      Selections.check_size();
    }
  },
  
  remove_some:function(journal_ids) {
    var params = {journal_id:journal_ids};
    new Ajax.Request('/selections/destroy_some', {asynchronous:true,method:'delete',parameters:params,onSuccess:function(){this.remove_some_success(journal_ids)}.bind(this)});
  },
  
  remove_all:function() {
    var params = Authorization.parameters({});
    new Ajax.Request('/selections/destroy_all', {asynchronous:true,method:'delete',parameters:params,onSuccess:this.remove_all_success.bind(this)});
  },
  
  remove_some_success:function(journal_ids) {
    var selection_dom_ids = new Array();
    var journal_id_array = journal_ids.split(Journal._id_delimiter);
    for(var i=0; i<journal_id_array.length; i++) {// Using standard loop because there could be a lot of array elements
      selection_dom_ids.push('selection_'+journal_id_array[i]);
    }
    
    $('deselect_all').hide();$('select_all').show();$('select_all').down('.little_spinner').hide();$('deselect_all').down('.little_spinner').hide();
    
    Selections.remove_multiple_elements(selection_dom_ids);
    
    if(Selections.selection_list().childElements().length == 0)
      Selections.hide();
  },
  
  remove_all_success:function() {
    var selections = this.selection_list().childElements();
    Selections.remove_multiple_elements(selections);
    Selections.hide();
  },
  
  remove_multiple_elements:function(selection_list) {
    for(var i=0; i<selection_list.length; i++) { // Using standard loop because there could be a lot of selections
      Selections._remove(selection_list[i]);
    }
  },
  
  refresh_compare_selected_url:function() {
    var journal_ids = []
    var href = $('compare_selected');
    Selections.selection_list().childElements().each(function(e) {
      journal_ids.push(Journal.Utilities.journalId(e));
    });
    
    href.href = '/journals/' + journal_ids.join(';');
  }
};

Authorization = {
  
  parameters:function(params){
    // Uncomment this if you are using Rails' authentication tokens
    //params[this.token_name()] = this.token_value();
    //return params;
    return params; 
  },
  
  token_name:function() {
    this.load_auth_token();
    return this.authorization_token_name;
  },
  
  token_value:function() {
    this.load_auth_token();
    return this.authorization_token_value;
  },
  
  load_auth_token:function() {
    if(!this.authorization_token_name || !this.authorization_token_value) {
      var auth_token = $('authenticity_token');
      this.authorization_token_name = auth_token.name;
      this.authorization_token_value = auth_token.getValue();
    }
  }
};

Medline = {
  text_terms: new Hash(),
  mesh_terms: new Hash(),
  effect_queue: {position:'end', scope:'medline'},
  
  /* 
   * Hides the instructional text, shows the link to PubMed, and shows the search terms used
   */
  show: function() {
    if( $('instructions').visible() ) {
      //$('instructions').hide();
      $('pubmed_articles_instructions').hide();
      $('pubmed_query_information').show(); // TODO: update to Effect.Appear
      this.hide_query(); // makes sure the pubmed_url_panel is hidden, and pubmed_description is visible
      $('pubmed_articles_link').show();
      $('pubmed_journal_articles_link').show();
    }
  },
  
  /* 
   * shows the instructional text, hides everything else 
   */
  hide: function() {
    //$('instructions').show(); // TODO: change to Effect.Appear
    $('pubmed_articles_instructions').show();
    $('pubmed_query_information').hide(); // TODO: update to Effect.Fade
    $('pubmed_articles_link').hide();
    $('pubmed_journal_articles_link').hide();
    
  },
  
  /*
   * Shows the URL of the pubmed query.
   */
  show_query: function () {
    $('pubmed_url_panel').show();
    $('pubmed_description').hide();
  },
   
   /*
    * hides the URL of the pubmed query.
    */
  hide_query: function () {
    $('pubmed_url_panel').hide();
    $('pubmed_description').show();
  },
   
   /* 
    * Used to toggle between the MeSH and Text Tabs
    */
   show_mesh_cloud: function() {
     $('mesh_cloud').show();
     $('text_cloud').hide();
     $('mesh_keyword_category').addClassName('selected');
     $('text_keyword_category').removeClassName('selected');
   },
   
   /* 
    * Used to toggle between the MeSH and Text Tabs
    */
   show_text_cloud: function() {
      $('mesh_cloud').hide();
      $('text_cloud').show();
      $('mesh_keyword_category').removeClassName('selected');
      $('text_keyword_category').addClassName('selected');
   },
  
   /*
    * Toggles a mesh term "on" or "off"
    * Uses the internal functions add_ and remove_mesh_term
    * to maintain our internal hashes. Merely a wrapper for toggle_term
    */
   toggle_mesh_term: function(elem) {   
     if( $(elem).hasClassName('selected') )
       this.toggle_term(elem, this.remove_mesh_term.bind(this));
     else
       this.toggle_term(elem, this.add_mesh_term.bind(this));
       
     this.update_selection_count($$('#mesh_keyword_category .selection_count').first(), this.mesh_terms.keys().length);
   },
   
   /*
    * Toggles a text term "on" or "off"
    * Uses the internal functions add_ and remove_text_term
    * to maintain our internal hashes. Merely a wrapper for toggle_term
    */
   toggle_text_term: function(elem) {
     if( $(elem).hasClassName('selected') )
      this.toggle_term(elem, this.remove_text_term.bind(this));
     else
      this.toggle_term(elem, this.add_text_term.bind(this));
      
     this.update_selection_count($$('#text_keyword_category .selection_count').first(), this.text_terms.keys().length);
   },
   
   /*
    * This DOES THE WORK for toggle_text_term and toggle_mesh_term.
    * 
    * It: 
    *  - adds or removes the term from the appropriate internal hash
    *  - applies or removes the appropriate html class to the term HTML element
    *  - fires off an AJAX request to PubMed
    *  - updates the href URL on our link to PubMed
    */
   toggle_term: function(element, term_manipulator_function) {
     element = $(element);
     var term = element.innerHTML;
     
     element.toggleClassName('selected');
     term_manipulator_function(term);  // [add/remove]_[mesh/text]_term() -- for internal hashes. MUST be called BEFORE the AJAX request.
     this.update_publication_count();  // Send AJAX
     this.update_link_urls();          // Update the href on the link to pubmed
     this.update_term_list();          // Update the text that lists the current search terms
     
     if( this.mesh_terms.keys().length > 0 || this.text_terms.keys().length > 0 ) {
       this.show();
     } else {
       this.hide();
     }
   },
   
   update_term_list:function () {
     var join_clause = ' + ';
     var joined_text = this.text_terms.values().join(join_clause);
     var joined_mesh = this.mesh_terms.values().join(join_clause);
     var terms = "";
     
     terms += joined_text;
     if ( !joined_text.empty() && !joined_mesh.empty() ) { terms += join_clause; }
     terms += joined_mesh;
     $('pubmed_search_terms').update(terms);
   },
   
   /*
    * Updates the href attribute of the 'pubmed_articles_link' element. Additionally
    * it updates the 'pubmed_url' element to allow the user to see the url itself
    */
   update_link_urls: function() {
     var url = 'http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=Search&term=' + this.get_query_terms();
     $('pubmed_articles_link').writeAttribute('href', url);
     $('pubmed_url').update(url);
     
     
     var url = 'http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=Search&term=' + '(' + this.journal_title_query_terms() + ')+AND+' + this.get_query_terms();
      $('pubmed_journal_articles_link').writeAttribute('href', url);
   },
   
   
   /*
    * Updates the number of selected terms in the MeSH and Text Word tabs
    */
   update_selection_count:function(count_elem, num_terms) {
     if(num_terms > 0) {
      count_elem.update('(' + num_terms + ')');
    } else {
      count_elem.update('');
    }
   },
   
   /*
    * Adds and removes Text and Mesh terms from the hashes. Internal use only.
    */
   add_text_term: function(term) { this.text_terms.set(term, new TextTerm(term)); },

   remove_text_term: function(term) { this.text_terms.unset(term); },
   
   add_mesh_term: function(term) { this.mesh_terms.set(term, new MeshTerm(term)); },
   
   remove_mesh_term: function(term) { this.mesh_terms.unset(term); },
   
   /*
    * Sends an AJAX request off to PubMed to see how many articles the selected terms will return
    */
   update_publication_count: function() {
     var base_url = '/pubmed_count';
     var terms    = this.get_query_terms();
     var url      = base_url + '?term=' + terms;
     
     new Ajax.Request(url, {
       method: 'get',
       onSuccess: function(transport) {
         var count_element = $('pubmed_count');
         if(transport.status == 204) {
           count_element.update(0);
         } else {
           count_element.update(transport.responseText);
           new Effect.Highlight('pubmed_link', {startcolor: '#ffff99', endcolor: '#f5fcff'} );
         }
       }
     });
     
     var base_url = '/pubmed_count';
     var terms    = '(' + this.journal_title_query_terms() + ')+AND+' + this.get_query_terms();
     var url      = base_url + '?term=' + terms;
     
     new Ajax.Request(url, {
       method: 'get',
       onSuccess: function(transport) {
         var count_element = $('pubmed_journal_count');
         if(transport.status == 204) {
           count_element.update(0);
         } else {
           count_element.update(transport.responseText);
           //new Effect.Highlight('pubmed_link', {startcolor: '#ffff99', endcolor: '#f5fcff'} );
         }
       }
     });
   },
   
   /*
    * Takes the MeSH and Text term hashes and builds GET params out of them
    */
   get_query_terms: function() {
     var join_clause = '+AND+';
     var joined_text = this.text_terms.values().invoke('to_param').join(join_clause);
     var joined_mesh = this.mesh_terms.values().invoke('to_param').join(join_clause);
     var query_terms = "";
     
     query_terms += joined_text;
     if ( !joined_text.empty() && !joined_mesh.empty() ) { query_terms += join_clause; }
     query_terms += joined_mesh;
     
     return query_terms;
   },
   
   journal_title_query_terms:function(){
     var join_clause = '[TA]+OR+';
     var terms = $$('.journal_title').map(function(title){return escape(title.innerHTML.unescapeHTML())}).join(join_clause)+'[TA]';
     return terms;
   }
};

Term = Class.create({
  initialize: function(term) { this.term = term; },
  
  to_param: function() { return this.normalized_term(); },
  
  toString: function() { return this.term; },
  
  normalized_term: function() {
    if(!this._normalized_term) { 
      this._normalized_term = encodeURIComponent(this.term);
      this._normalized_term = this._normalized_term.gsub(/(%20)+/, "+");
    }
    return this._normalized_term;
  }
});

MeshTerm = Class.create(Term, {
  initialize: function($super, term) { $super(term); },
  to_param: function() { return this.normalized_term() + '[mh]'; }
});

TextTerm = Class.create(Term, {
  initialize: function($super, term) { $super(term); },
  to_param: function() { return this.normalized_term() + '[tw]'; }
});

