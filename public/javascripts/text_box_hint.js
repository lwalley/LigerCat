var TextBoxHint = {
  add: function(element, text, klass){
    element = $(element);
    text = text || '';
    klass = klass || 'empty';
    
    element.addEvents({
      'focus': function(event) {
        if(event.target.hasClass(klass)) { event.target.set('value', ''); event.target.removeClass(klass); }
      },
      'blur' : function(event) {
        if(event.target.get('value') === '') { event.target.set('value', text); event.target.addClass(klass);}
      }
    });
    
    element.fireEvent('blur', {target:element});
  }
};