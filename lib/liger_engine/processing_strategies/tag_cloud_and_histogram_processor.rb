require 'ostruct'

# A LigerEngine Processing Strategy is responsible for taking 
# an array of Pubmed IDs
#
# It must implement the instance method +process+, which accepts a
# query String and returns an array of Integer Pubmed IDs
module LigerEngine
  module ProcessingStrategies
    # This is a Composite for generating a histogram and tag cloud for a list of PMIDs
    #
    # This could be handled more elegantly with a bit of metaprogramming, but I'm
    # keeping it simple for now.
    class TagCloudAndHistogramProcessor
      def initialize
        @tag_cloud = TagCloudProcessor.new
        @histogram = HistogramProcessor.new
      end
      
      def process(id_list)
        OpenStruct.new({ :tag_cloud => @tag_cloud.process(id_list),
                         :histogram => @histogram.process(id_list) } )
      end
    end
  end
end