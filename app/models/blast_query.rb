require "blast"
require 'digest/md5'

class BlastQuery < Query
  
  has_one :sequence, :dependent => :delete, :foreign_key => 'query_id'
  
  attr_accessor :fasta_data
  
  attr_accessible :fasta_data
  
  validates_presence_of :fasta_data
  
  after_create :make_sequence
  
    
  class << self
    def find_by_sequence(fasta_data)
      find_by_key create_key(fasta_data)
    end
  end
  
  def make_sequence
    create_sequence(:fasta_data => fasta_data)
  end
  
  def search_strategy
    sequence_type = sequence.amino_acid? ? :amino_acid : :nucleotide 
    LigerEngine::SearchStrategies::GenbankSearchStrategy.new(sequence_type) 
  end
  
  def query
    fasta_data || self.sequence.fasta_data
  end
  
  def humanized_state
    self.state == :searching ? "Blasting" : super
  end
end
