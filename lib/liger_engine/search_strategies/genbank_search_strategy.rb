# A LigerEngine Search Strategy is responsible for taking some sort
# of input, and turning it into an array of Integer Pubmed IDs
#
# It must implement the instance method 'search', which accepts a
# query String and returns an array of Integer Pubmed IDs

module LigerEngine
  module SearchStrategies
    # The Genbank search strategy accepts a FASTA-formatted gene sequence as
    # its query input, and uses the BLAST algorithm, along with a local lookup
    # database to generate a list of Pubmed IDs that mention the given sequence
    #
    # You must tell the Genbank search strategy which BLAST algorithm to use 
    # by passing in either :amino_acid or :nucleotide to its constructor
    #
    # Author:: Ryan Schenk (mailto:rschenk@mbl.edu)

    class GenbankSearchStrategy
      attr_accessor :blast_algorithm
  
      # === Parameters
      # * _type_ - a Symbol that can be either :amino_acid or :nucleotide. This determines which BLAST algorithm to use
      def initialize(type)
        case type
        when :amino_acid : @blast_algorithm = TBlastN.new
        when :nucleotide : @blast_algorithm = BlastN.new
        else raise ArgumentError, "The type parameter must be either :amino_acid or :nucleotide"
        end
      end
  
      # Performs a BLAST search for the given query, which is translated into a list of PMIDs with a local lookup table
      #
      # Returns an array of PMIDs as Integers
      #
      # === Parameters
      # * _query_ - A string to send to Pubmed
      def search(query)
        blast_results = @blast_algorithm.search(query)
        gi_numbers = blast_results.map{|r| r[:gi_number] }
    
        pmids = PmidGenbank.find_all_by_gi_number(gi_numbers).map{|pmid_ar| pmid_ar.pmid }
    
        pmids
      end
    end
  end
end