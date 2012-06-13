# This is a helper mixin to try to keep the processing strategies DRY while 
# still being flexible
#
# For full documentation see the class-level documentation for 
# ProcessingStrategyHelper
#
# Author:: Ryan Schenk (mailto:rschenk@mbl.edu)

module LigerEngine
  module ProcessingStrategies
    
    
    # A processing strategy needs to do four things:
    # 1. Accept a list of IDs
    # 2. Look up those IDs locally, and process the ones we have locally
    # 3. Fetch the ones that we don't have locally from PubMed
    # 4. Save the fetched ones locally, then process them
    #
    # The only requirement for a LigerEngine Processing Strategy is that it
    # respond to the +process+ method. This is a helper module for imposing 
    # some structure outlined above. If the above workflow does not fit in 
    # with your particular processing strategy, then there is absolutely no 
    # reason to use this helper. If it does, however, it will save you a bit 
    # of coding.
    #
    # When your class includes ProcessingStrategyHelper, then you must *not* 
    # define a +process+ method in your own class, it is defined in the 
    # helper. Instead, you must define three methods: +each_id+, 
    # +each_nonlocal+, and +return_results+. These methods are explained 
    # below.
    #
    # The +process+ method defined in this helper loops through the list of 
    # IDs, calling the method +each_id+ with each one. +each_id+ must do 
    # something rather special. It must look up the given ID locally. If it 
    # exists, it should do something useful and return true (or more 
    # accurately non-false). If the ID does not exist locally, +each_id+ 
    # must return *false* or *nil*.  When it does, the 
    # ProcessingStrategyHelper will automatically add that ID to the list of 
    # nonlocal IDs.
    #
    # When each ID has been processed, ProcessingStrategyHelper will
    # automatically go and fetch the nonlocal ids from PubMed. It will pass 
    # each one to the method +each_nonlocal+ as a Nokogiri::XML::Element object. 
    # +each_nonlocal+ should process the Nokogiri::XML::Element object, and I would 
    # suggest it get cached locally so that it will never have to be looked up  
    # again.
    #
    # Lastly, the +return_retults+ method is called. You can do whatever you 
    # need to in this method to get your object ready to be returned. Whatever 
    # is returned by +return_results+ is returned by 
    # ProcessingStrategyHelper#process.

    
    class Base < Strategy
      # Accepts a list of IDs and does something useful with them.
      #
      # Every Processing Strategy must define this method, and this particular 
      # helper provides a general structure for you, so you don't have to.
      # You should not define _process_ in the class that mixes in this 
      # helper.
      #
      # The details of this method are outlined in the class-level docs and
      # in the comments above the other methods in this class, so I'll avoid 
      # repeating myself.
      #
      # === Parameters
      # * _id_list_: An array of integers of Pubmed IDs
      #
      # === Returns
      # * The results of the processing
      def process(id_list)
        nonlocal_ids = []
                
        log "Looking up #{id_list.length} IDs in local caches"
        # Loop through each ID from the list sent by the Search Strategy
        id_list.each do |id|
          unless each_id(id)
            nonlocal_ids << id
          end
        end
        
        
        log "Retrieving #{nonlocal_ids.length} nonlocal IDs that were not in the local cache"
        # Retrieve unannotated IDS and add those to the histogram.
        unless nonlocal_ids.empty?
          LigerEngine::PubmedFetcher.fetch(nonlocal_ids) do |medline_citation|
            each_nonlocal(medline_citation)
          end
        end
            
        return_results
      end
      
      # +process+ loops through the list of IDs, calling the +each_id+ 
      # with each one. 
      #
      # +each_id+ must do something rather special. 
      #
      # It must look up the given ID locally. If the ID exists locally, do 
      # something useful and return true (or more accurately non-false). 
      #
      # If the ID does not exist locally, +each_id+ must return *false* or
      # *nil*.  
      # When it does, the ProcessingStrategyHelper will automatically 
      # add that ID to the list of nonlocal IDs.
      # 
      # === Parameters
      # * _id_: an integer Pubmed ID
      #
      # === Should Return
      # * "true" (non-false and non-nil) if the ID can be found locally
      # * false or nil if the ID needs to be retrieved from PubMed
      def each_id(id)
        raise 'You must define each_id in your Processor'
      end
      
      # When each ID has been processed, ProcessingStrategyHelper will
      # automatically go and fetch the nonlocal ids from PubMed.
      #  
      # This method is called with each one as a Nokogiri::XML::Element object,
      # representing the PubmedArticle node of the eFetch XML Response. See
      # LigerEngine::PubmedFetcher for a discussion on how this is fuct and how to fix it. 
      # +each_nonlocal+ should process the Nokogiri::XML::Element object, and I would 
      # suggest it get cached locally so that it will never have to be looked 
      # up again.
      #
      # === Parameters
      # * _medline_citation_: a Nokogiri::XML::Element object representing a PubmedArticle
      # from the eFetch response
      def each_nonlocal(medline_citation)
        raise 'You must define each_nonlocal in your Processor'
      end
      
      # This method is called as the last step of _process_. You can do 
      # whatever you need to in this method to get your object ready to be 
      # returned. 
      #
      # === Should Return
      # * Whatever is returned by +return_results+ is returned by ProcessingStrategyHelper#process.
      def return_results
        raise 'you must define return_results in your Processor'
      end
    end
  end
end