require 'rubygems'
require 'nokogiri'
require 'bio'

module LigerEngine
  # PubmedFetcher accepts a list of Pubmed IDs, performs an eFetch
  # and gives iterator access to each pubmed citation as a
  # Nokogiri::XML::Element object.
  #
  # Why have I coupled this class -- and thus any processing strategy
  # that includes the ProcessingStrategyHelper -- so tightly with
  # Nokogiri? Why don't I create an object that abstracts the underlying
  # XML structure? 
  #
  # Originally this class would pass a full Bio::MEDLINE object to the block
  # but this consumed so much memory that even a trivial record set would make
  # my Mac Pro start swapping. 
  #
  # TODO: Refactor this to pass some sort of Proxy object to the block to hide
  # the XML implementation, while still being fairly memory efficient
  class PubmedFetcher
    # Accepts a list of Pubmed IDs, performs an eFetch, and
    # passes each result as a Nokogiri::XML::Element object to the given block
    def self.fetch(pmid_list, &block)

      # It turns out that EFetch has a limit of approximately 7,000 PMIDs per efetch.
      # So we have to do them in batches of 7,000.
      #
      # TODO: This is a great opportunity speed things up by parallelizing/mapreducing.
      # Instead of fetching each batch in serial, we could fetch and process them in parallel
      pmid_list.in_groups_of(7000) do |pmids|
        results = Bio::NCBI::REST.efetch(pmids, { "db" => "pubmed", "rettype" => 'medline', "retmode" => 'xml', "tool" => 'ligercat', "email" => 'hmiller@mbl.edu' }, 100000)            
        doc = Nokogiri::XML(results)
        doc.xpath('/PubmedArticleSet/PubmedArticle').each do |pubmed_article|
          yield(pubmed_article)
        end
      end
    end
    
  end
end