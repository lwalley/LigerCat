//= require ligercat

/* 
 * Ligercat.SelectedTerms is a collection of term objects:
 *   term: { name: '', id: 123 }
 *
 * As users click on MeSH terms in the cloud, they are added to
 * this collection. Other interested parties can listen for events
 * and respond accordingly.
 *
 * events: 
 *   add: function(event, term)
 *   remove: function(event, term)
 *   empty: function(event)
 *   change: function(event, array_of_all_terms)
 */
Ligercat.SelectedTerms = {
	
	$: $({}),
	_terms: new Object(),
	
	// facade over Ligercat.SelectedTerms.$.on 
	on: function(){ Ligercat.SelectedTerms.$.on.apply(Ligercat.SelectedTerms.$, arguments); },
	
	// can be called with:
	// 	add(123, 'abc')
	// 	add({id:123, name:'abc'})
	add: function(id_or_term, name){
		var t;
		_.isObject(id_or_term) ? t = id_or_term : t = {id: id_or_term, name: name };
	
		Ligercat.SelectedTerms._terms[t.id] = t;
		Ligercat.SelectedTerms.$.trigger('add', t);
		Ligercat.SelectedTerms.$.trigger('change', [_.values(Ligercat.SelectedTerms._terms)]);
	},
	
	// Term can be an ID number or a Term object
	remove: function(id_or_term){
		var id,
		    term,
			terms;
			
		_.isNumber(id_or_term) ? id = id_or_term : id = id_or_term.id;
			
		term = Ligercat.SelectedTerms._terms[id];
			
		if( term !== undefined ) {
			
			delete Ligercat.SelectedTerms._terms[id];
			
			terms = _.values(Ligercat.SelectedTerms._terms);
			
			if( terms.length > 0 ){
				Ligercat.SelectedTerms.$.trigger('remove', term);
				Ligercat.SelectedTerms.$.trigger('change', [terms]);
			} else {
				Ligercat.SelectedTerms.$.trigger('empty');
			}
			
		}
	},
	
	toggle: function(id_or_term, name) {
		var t;
		_.isObject(id_or_term) ? t = id_or_term : t = {id: id_or_term, name: name };
		
		if( Ligercat.SelectedTerms._terms[t.id] === undefined ){
			Ligercat.SelectedTerms.add(t);
		} else {
			Ligercat.SelectedTerms.remove(t) 	
		}
	},
	
	empty: function(){
		Ligercat.SelectedTerms._terms = new Object();
		Ligercat.SelectedTerms.$.trigger('empty');
	}
};