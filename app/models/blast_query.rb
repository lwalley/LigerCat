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
  
  def search_strategy
    sequence_type = sequence.amino_acid? ? :amino_acid : :nucleotide 
    LigerEngine::SearchStrategies::GenbankSearchStrategy.new(sequence_type) 
  end
  
  def query
    self.sequence.fasta_data
  end
  
  def humanized_state
    self.state == :searching ? "Blasting" : super
  end
end
