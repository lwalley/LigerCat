require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlastMeshFrequency, '#score' do
  fixtures :blast_mesh_frequencies, :mesh_keywords
  
  it "should use the genbank_score column, not the score column" do
    humans_freqs = blast_mesh_frequencies(:humans)
    humans_freqs.score.should == mesh_keywords(:humans).genbank_score
    humans_freqs.score.should_not == mesh_keywords(:humans).score
    humans_freqs.weighted_frequency.should == humans_freqs.frequency - (humans_freqs.frequency * mesh_keywords(:humans).genbank_score)
    
    molecular_sequence_data_freqs = blast_mesh_frequencies(:molecular_sequence_data)
    molecular_sequence_data_freqs.score.should == mesh_keywords(:molecular_sequence_data).genbank_score
    molecular_sequence_data_freqs.score.should_not == mesh_keywords(:molecular_sequence_data).score
    molecular_sequence_data_freqs.weighted_frequency.should == molecular_sequence_data_freqs.frequency - (molecular_sequence_data_freqs.frequency * mesh_keywords(:molecular_sequence_data).genbank_score)
  end
end
