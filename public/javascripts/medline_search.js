var Ligercat=Ligercat||{};

Ligercat.MedlineSearch = new Class({
  initialize:function(success_callback, optional_scope){
    this.optional_scope = optional_scope || '';
    this.base_url = '/pubmed_count';
    this.journals = []; // Journal Titles
    this.request  = new Request({url: this.base_url, link:'cancel', method:'get'});
    this.request.addEvents({'success':function(count){ success_callback(count.toInt(), this.direct_pubmed_link); } });
  },
  
  getArticleCount:function(mesh_terms, text_words) {
		this.request.direct_pubmed_link = this.directPubmedLink(mesh_terms, text_words); // This allows the onSuccess callback to pass in a direct link to pubmed
		
    this.request.send('term=' + this._createQueryTerms(mesh_terms, text_words));
  },
  
  directPubmedLink:function(mesh_terms, text_words) {
    return 'http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=Search&term=' + this._createQueryTerms(mesh_terms, text_words);
  },
  
  _createQueryTerms:function(mesh_terms, text_words){
    mesh_terms = mesh_terms || [];
    text_words = text_words || [];
    var join_clause = '+AND+';
    var joined_mesh   = mesh_terms.map(function(t){    return (escape('"' + t + '"[mh]')); }).join(join_clause);
    var joined_text   = text_words.map(function(t){    return (escape('"' + t + '"[tw]')); }).join(join_clause);
    var joined_titles = this.journals.map(function(t){ return (escape('"' + t + '"[TA]')); }).join('+OR+');
    var query_terms = "";
    
    if(this.journals.length > 0) { 
      query_terms += '('+joined_titles+')+AND+';
    }
    
    query_terms += joined_text;
    if( text_words.length > 0 && mesh_terms.length > 0 ) { query_terms += join_clause; }
    query_terms += joined_mesh;

    if( this.optional_scope ) {
      query_terms = "("+this.optional_scope+") AND ("+query_terms+")";
    }

    return query_terms;
  }
});