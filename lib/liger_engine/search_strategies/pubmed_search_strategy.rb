#
# A LigerEngine Search Strategy is responsible for taking some sort
# of input, and turning it into an array of Integer Pubmed IDs
#
# It must implement the instance method 'search', which accepts a
# query String and returns an array of Integer Pubmed IDs
#

module LigerEngine
  module SearchStrategies

    # The Pubmed search strategy accepts a string as its query input,
    # sends it to PubMed via eSearch, and generates a list of Pubmed IDs
    # with the results
    #
    # Author:: Ryan Schenk (mailto:rschenk@mbl.edu)

    class PubmedSearchStrategy
  
      # Accepts a String to send to Pubmed, and returns an Array of Integer PMIDs that result.
      # === Parameters
      # * _query_ - A string to send to Pubmed
      def search(query)
        results = PubmedSearch.search(query, :tool => 'ligercat', :email => 'hmiller@mbl.edu', :load_all_pmids => true)
        results.pmids
      end
    end
  end
end