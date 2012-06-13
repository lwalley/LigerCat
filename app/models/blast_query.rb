require "#{RAILS_ROOT}/lib/blast"
require 'digest/md5'

class BlastQuery < AsynchronousQuery
  
  has_many :blast_mesh_frequencies, :dependent => :destroy
  has_many :mesh_frequencies, :class_name => 'BlastMeshFrequency'
  has_many :mesh_keywords, :through => :blast_mesh_frequencies
  
  has_many :publication_dates, :as => :query do
    def to_histohash
      returning Hash.new(0) do |histohash|
        find(:all).each{|pub_date| histohash[pub_date.year] = pub_date.publication_count }
      end
    end
  end  
    
  has_one :sequence, :dependent => :destroy
  
  attr_accessor :fasta_data
  
  validates_presence_of :fasta_data
    
  class << self
    def find_by_sequence(fasta_data)
      find_by_query_key create_query_key(fasta_data)
    end
    
    def create_query_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
  end
  
  def before_create
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

    results.tag_cloud.each do |mesh_frequency|
      self.blast_mesh_frequencies.build(mesh_frequency)
    end

    results.histogram.each do |year, publication_count|
      self.publication_dates.build(:year => year, :publication_count => publication_count)
    end
    
    self.save
  end
  
  # Observer method for LigerEngine
  def liger_engine_update(event_name, *args)
    case event_name
    when :before_search               : self.update_state(:searching)
    when :before_processing           : self.update_state(:processing)
    when :before_tag_cloud_processing : self.update_state(:processing_tag_cloud)
    when :before_histogram_processing : self.update_state(:processing_histogram)
    end
  end
  
  def humanized_state
    self.state == :searching ? "Blasting" : super
  end
    
  
  
  
end