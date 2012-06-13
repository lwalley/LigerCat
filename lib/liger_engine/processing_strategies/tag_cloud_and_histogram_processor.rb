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
    class TagCloudAndHistogramProcessor < Base
      def initialize
        @tag_cloud = TagCloudProcessor.new
        @histogram = HistogramProcessor.new
        
        @tag_cloud.add_observer self, :forward_notification
        @histogram.add_observer self, :forward_notification
      end
      
      def process(id_list)
          changed; notify_observers :before_tag_cloud_processing, id_list.count
        tag_cloud_results =  @tag_cloud.process(id_list)
          changed; notify_observers :after_tag_cloud_processing
        
          changed; notify_observers :before_histogram_processing, id_list.count
        histogram_results = @histogram.process(id_list)
          changed; notify_observers :after_histogram_processing
          
        
        OpenStruct.new({ :tag_cloud => tag_cloud_results,
                         :histogram => histogram_results } )
      end
    end
  end
end