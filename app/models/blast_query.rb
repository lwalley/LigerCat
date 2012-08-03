require "blast"
require 'digest/md5'

class BlastQuery < AsynchronousQuery
  before_create :set_query_key
  
  has_many :blast_mesh_frequencies, :dependent => :delete_all
  has_many :mesh_frequencies, :class_name => 'BlastMeshFrequency'
  has_many :mesh_keywords, :through => :blast_mesh_frequencies
  has_many :publication_dates, :as => :query, :dependent => :delete_all do
    def to_histohash
      Hash.new(0).tap do |histohash|
        self.all.each{|pub_date| histohash[pub_date.year] = pub_date.publication_count }
      end
    end
  end  
    
  has_one :sequence, :dependent => :destroy
  
  attr_accessor :fasta_data
  attr_accessible :fasta_data, :state
  
  validates_presence_of :fasta_data
  
    
  class << self
    def find_by_sequence(fasta_data)
      find_by_query_key create_query_key(fasta_data)
    end
    
    def create_query_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
  end
  
  def set_query_key
    self.query_key = self.class.create_query_key(fasta_data)
    build_sequence(:fasta_data => fasta_data)
  end
  
  # Uniform interface for all AsynchronousQuery's
  def perform_query!
    sequence_type = sequence.amino_acid? ? :amino_acid : :nucleotide 
    search  = LigerEngine::SearchStrategies::GenbankSearchStrategy.new(sequence_type) 
    process = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    engine  = LigerEngine::Engine.new(search,process)
    engine.add_observer(self, :liger_engine_update)
    
    results = engine.run(sequence.fasta_data)

    self.blast_mesh_frequencies.clear
    results.tag_cloud.each do |mesh_frequency|
      self.blast_mesh_frequencies.build(mesh_frequency)
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
