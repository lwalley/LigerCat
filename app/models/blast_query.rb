require "blast"
require 'digest/md5'

class BlastQuery < Query
  
  has_one :sequence, :dependent => :destroy, :foreign_key => 'query_id'
  
  attr_accessor :fasta_data
  attr_accessible :fasta_data
  
  validates_presence_of :fasta_data
  
    
  class << self
    def find_by_sequence(fasta_data)
      find_by_key create_key(fasta_data)
    end
    
    def create_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
  end
  
  def set_key
    self.key = self.class.create_key(fasta_data)
    build_sequence(:fasta_data => fasta_data)
  end
  
  # Uniform interface for all Query's
  # TODO refactor this into Query
  def perform_query!
    sequence_type = sequence.amino_acid? ? :amino_acid : :nucleotide 
    search  = LigerEngine::SearchStrategies::GenbankSearchStrategy.new(sequence_type) 
    process = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    engine  = LigerEngine::Engine.new(search,process)
    engine.add_observer(self, :liger_engine_update)
    
    results = engine.run(sequence.fasta_data)

    self.mesh_frequencies.clear
    results.tag_cloud.each do |mesh_frequency|
      self.mesh_frequencies.build(mesh_frequency)
    end
    
    self.publication_dates.clear
    results.histogram.each do |year, publication_count|
      self.publication_dates.build(:year => year, :publication_count => publication_count)
    end
    
    self.save
  end
  
  def humanized_state
    self.state == :searching ? "Blasting" : super
  end
end
