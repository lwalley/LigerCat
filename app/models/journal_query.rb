class JournalQuery < AsynchronousQuery
  
  has_many :results, :class_name => 'JournalResult', :dependent => :destroy
  has_many :journal_results, :dependent => :destroy
  has_many :journals, :through => :journal_results
  
  validates_presence_of :query
    
  class << self
    
    def perform(query_id)
      query = JournalQuery.find(query_id)
      query.perform_query!
      query.update_attribute(:done, true)
    rescue Exception => e
      # TODO: make an error flag in the database to alert user to an error
      raise e # Resque handles this and puts it in the Failed Jobs list
    end
    
    def find_by_query(query)
      find_by_query_key create_query_key(query)
    end
    
    def create_query_key(query)
      Digest::MD5.hexdigest(query.strip.downcase)
    end
  end
  
  def before_create
    self.query_key = self.class.create_query_key(query)
  end
  
  def perform_query!
    logger.info "INFO: Querying NLM for: #{self.query}"
        
    nlm_journals = NLMJournalSearch.new(self.query).search
    results_map = {}
    
    logger.info "INFO: Retrieved #{nlm_journals.size} journals from NLM"
    
    nlm_journals.each do |j|
      results_map[j.id] = self.results.build(:journal_id => j.id, :search_term_score => j.rank)
    end
    
    
    
    logger.info "INFO: Built #{results_map.size} results"
    
    # I used to do it this way, but this required saving all the results, then updating all of them in the following loops.
    # that takes time, however, this query is slightly faster fast.
    # journal_mesh = self.journals.find(:all, :include => {:journal_mesh_frequencies => :mesh_keyword})
    # journal_text = self.journals.find(:all, :include => {:journal_text_frequencies => :text_keyword})
    
    # Now I load all the journals for this query with a giant WHERE id IN( big_array ). It's slow, but not as slow as writing the results twice
    journal_mesh = Journal.find(results_map.keys, :include => {:journal_mesh_frequencies => :mesh_keyword})
    journal_text = Journal.find(results_map.keys, :include => {:journal_text_frequencies => :text_keyword})
    
    logger.info "INFO: Retrieved #{journal_mesh.size} journals from the database, joining with mesh_keywords"
    
    mesh_occurances = {}
    text_occurances = {}
    self.max_mesh_score = 0
    self.max_text_score = 0

    # Sum # of occurances of every mesh keyword
    journal_mesh.each do |journal|
      journal.journal_mesh_frequencies.each do |freq|
        kw_name = freq.mesh_keyword.name 
        if mesh_occurances.has_key?(kw_name) 
          mesh_occurances[kw_name] += 1
        else
          mesh_occurances[kw_name] = 1
        end
      end
    end
    
    logger.info "INFO: number of mesh occurances: #{mesh_occurances.size}"
    
    # Sum # of occurances of every text keyword
    journal_text.each do |journal|
      journal.journal_text_frequencies.each do |freq|
        text_name = freq.text_keyword.name
        if text_occurances.has_key?(text_name) 
          text_occurances[text_name] += 1
        else
          text_occurances[text_name] = 1
        end
      end
    end

    logger.info "INFO: number of text occurances: #{text_occurances.size}"
    
    # Loop through all the journals and their mesh terms, weight each one, and save that as the result.mesh_score  
    journal_mesh.each do |journal|
      mesh_score = 0

      journal.journal_mesh_frequencies.each do |mesh_freq|
        mesh_score += mesh_freq.frequency * mesh_occurances[mesh_freq.mesh_keyword.name]
      end
      r = results_map[journal.id]
      r.mesh_score = mesh_score
      
      self.max_mesh_score = mesh_score if mesh_score > self.max_mesh_score
    end
    
    # Loop through all the journals and their text terms, weight each one, and save that as the result.text_score
    journal_text.each do |journal|
      text_score = 0
      journal.journal_text_frequencies.each do |text_freq|
        text_score += text_freq.frequency * text_occurances[text_freq.text_keyword.name]
      end
      
      r = results_map[journal.id]
      r.text_score = text_score
      
      self.max_text_score = text_score if text_score > self.max_text_score
    end
        
    logger.info "INFO: max mesh score: #{max_mesh_score}"
    logger.info "INFO: max text score: #{max_text_score}"
    
    self.save
    
    logger.info "INFO: Saved JournalQuery and Journal Results"
  end
end
