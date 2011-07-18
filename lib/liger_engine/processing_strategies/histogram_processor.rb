require 'rubygems'
require 'treetop'
require 'date_published_parser'

module LigerEngine
  module ProcessingStrategies
    # The HistogramProcessor takes a list of PMIDs, and builds a histogram
    # from the Date of Publication of all those PMIDs
    class HistogramProcessor
      include ProcessingStrategyHelper
      
      attr_accessor :histogram
      attr_accessor :redis
      attr_reader   :date_published_parser
  
      def initialize
        @date_published_parser = DatePublishedParser.new
        @histogram = Hash.new(0)
        @redis = RedisFactory.gimme('date_published')
      end
  
  
      # Is called with every PMID given to the processor.
      # 
      # Each PMID should be looked up locally. If it exists locally, it is added
      # to the histogram. If it doesn't exist, this method will return nil
      def each_pmid(pmid)
        if dp_str = @redis.get(pmid)
          date_published = Date.parse(dp_str)
          add_to_histogram(date_published)
        end
      rescue SystemCallError => e
        raise "Could not connect to Redis!"
      end
      
      # Take the medline citation, parse the date. If it works, insert into DB and add to Histogram
      def each_nonlocal(pubmed_article_xml)      
        pub_date_node = pubmed_article_xml.xpath('./MedlineCitation/Article/Journal/JournalIssue/PubDate').first
        pub_date_content = if medline_date = pub_date_node.xpath('./MedlineDate').first
                             medline_date.content
                           else
                             pub_date_node.content.strip.gsub(/\s+/, ' ')
                           end

        date_published = @date_published_parser.parse(pub_date_content)
        
        unless date_published.nil? or !date_published.valid?
          pmid = pubmed_article_xml.xpath('./MedlineCitation/PMID').first.text
        
          add_to_histogram(date_published.to_date)
          @redis.set(pmid, date_published.to_date.to_s)
        end
      rescue SystemCallError => e
        raise "Could not connect to Redis!"
      end
      
      def return_results
        @histogram
      end
  
      private 
  
      # This method takes a Date object and adds it to the histogram
      # 
      # It exists because this process needs to be done twice, once
      # for PMIDs that we have locally, and again for the PMIDs that
      # we had to retrieve from Pubmed
      def add_to_histogram(date)
        self.histogram[date.year] =  self.histogram[date.year] + 1
      end
    end
  end
end