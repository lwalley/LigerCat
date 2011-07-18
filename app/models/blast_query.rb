require "#{RAILS_ROOT}/lib/blast"
require 'digest/md5'

class BlastQuery < ActiveRecord::Base
  include AsynchronousQuery
  
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
  
  after_create  :launch_worker
  
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
  def launch_worker
    BlastWorker.async_execute_search(:id => self.id)
  end
  
  # Uniform interface for all AsynchronousQuery's
  def perform_query!
    sequence_type = sequence.amino_acid? ? :amino_acid : :nucleotide 
    search  = LigerEngine::SearchStrategies::GenbankSearchStrategy.new(sequence_type) 
    process = LigerEngine::ProcessingStrategies::TagCloudAndHistogramProcessor.new
    engine  = LigerEngine::Engine.new(search,process)
    results = engine.run(sequence.fasta_data)

    results.tag_cloud.each do |mesh_frequency|
      self.blast_mesh_frequencies.build(mesh_frequency)
    end

    results.histogram.each do |year, publication_count|
      self.publication_dates.build(:year => year, :publication_count => publication_count)
    end
    
    self.save
  end
end