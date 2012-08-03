var Ligercat = {
  version: "2.0"
};

var FastaValidator = {
  validate: function(gene_form) {
    var fasta_data = gene_form.getElement('textarea').get('value');
    var errors = [];
    var valid = true;
    
    if(this.numSequencesInFastaData(fasta_data) > 1) {
      valid = false;
      errors.push("contains more than one sequence");
    }
    
    if(!valid){
      alert("LigerCat could not perform a BLAST because the text entered " + errors.join(",") + '.');
    }
    
    return valid;      
  },
  numSequencesInFastaData: function(fasta_data) {
    var lines = fasta_data.split("\n");
    var num_seqs = 0;
    lines.each(function(line){
      if(line.indexOf('>') > -1){
        num_seqs++;
      }
    }, this);
    return num_seqs;
  }
};
