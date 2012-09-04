//= require ligercat

Ligercat.PubmedQueryBuilder = {
  config:{
    scope: null
  },
  
  build: function(termList){
    var query = _.map(termList, function(t){ return '"' + t.name +'"[mh]'}).join(' AND ');
    
    if(Ligercat.PubmedQueryBuilder.config.scope) {
      query = "("+ Ligercat.PubmedQueryBuilder.config.scope + ") AND ("+query+")";
    }
    
    return query;
  }
};
