require File.expand_path(File.dirname(__FILE__) + '/pubmed_search_strategy')

#
# A LigerEngine Search Strategy is responsible for taking some sort
# of input, and turning it into an array of Integer Pubmed IDs
#
# It must implement the instance method 'search', which accepts a
# query String and returns an array of Integer Pubmed IDs
#

module LigerEngine
  module SearchStrategies
    # The EoL-specific Pubmed Search Strategy is the same as the regular
    # PubmedSearchStrategy, except that it transforms the query (assumed to be a binomial) into a special format that Holly devised for effectively searching for species names
    #
    # Author:: Ryan Schenk (mailto:rschenk@mbl.edu)

    class EolPubmedSearchStrategy < PubmedSearchStrategy
      attr_accessor :genus
      attr_accessor :species
      
      class << self
        # Accepts a string, and turns it into a special format for effectively searching Pubmed for species binomials
        #
        # Turns +Galaxias maculatus+ into +"Galaxias maculatus"[tiab] OR "Galaxias maculatus"[MeSH Terms] OR ("G. maculatus"[tiab] AND Galaxias[tiab])+
        def species_specific_query(binomial)
          @genus, @species = binomial.split(/\s/)

          %("#{binomial}"[tiab] OR "#{binomial}"[MeSH Terms] OR ("#{@genus.first}. #{@species}"[tiab] AND #{@genus}[tiab]))
        end
      end
  
      # Accepts a String that is assumed to be a binomial, and returns an Array of Integer PMIDs that result.
      # === Parameters
      # * _query_ - A species binomial
      def search(query)
        special_pubmed_query = self.class.species_specific_query(query)
    
        results = PubmedSearch.search(special_pubmed_query, :tool => 'ligercat', :email => 'hmiller@mbl.edu', :load_all_results => true)
    
        results.pmids
      end
    end
  end
end