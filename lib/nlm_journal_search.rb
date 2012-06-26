# TODO: Update this to use my new nlm_eutil_search class
require 'cgi'

class NLMJournalSearch
  def self.getValidSubjectTerms
    # puts "----READING AND LOADING JOURNAL SUBJECT TERMS----"
    validSubjectTermHash ={}
    File.open(RAILS_ROOT + "/lib/journalSubjectTerms.txt").each do |journalSubjectLine|
      journalSubjectLine.chomp!
      entryTerm,journalSubject = journalSubjectLine.split(/\|/)
      if validSubjectTermHash.has_key? entryTerm
        validSubjectTermHash[entryTerm] << journalSubject
      else
        validSubjectTermHash[entryTerm] = [journalSubject]
      end
    end
    validSubjectTermHash
  end
  def self.getStopWords
    # puts "----READING AND LOADING STOP WORDS----"
    stopWordHash= {}
    File.open(RAILS_ROOT + "/lib/journalStopWords.txt").each do |stopWord|
      stopWord.chomp!
      stopWordHash[stopWord.downcase] = 1
    end
    stopWordHash
  end
  
  @@validSearchTermHash = getValidSubjectTerms
  @@stopWordHash = getStopWords
  
  @@subjectTermThreshold         = 0.125 # Defined as class var now. Might need to change to instance var when adding in intelligence?
  @@searchTermThresholdDecrement = 0.01  # Ditto
  @@searchTermThresholdStart     = 0.16
  
  attr_reader :nlmJournalList 
  attr_reader :subjectTermHash
  attr_reader :searchTermHash

  def initialize(subject_terms)
    subject_terms = [subject_terms] if subject_terms.is_a? String
    raise ArgumentError, "Expected an array of subject terms" unless subject_terms.respond_to?(:length) && subject_terms.length > 0
    
    # Initialize journal list and search term lists as empty hashes
    @nlmJournalList  = {}
    @subjectTermHash = {}
    @searchTermHash  = {}
    @initial_subject_term_hash = {}
    
    # Normalize initial subject terms, and put them into the lookup hash
    # and include other valid subject terms
    subject_terms.each do |term|
      @subjectTermHash[ normalize_subject_term(term) ] = 0
      if @@validSearchTermHash.has_key? term
        @@validSearchTermHash[term].each{|t| @subjectTermHash[t] = 0}
      end
    end
    
    # We need to keep track of the subject terms that the user entered for our search ranking,
    # and since searchTermHash is added to on every iteration, we keep the initial results here
    @subjectTermHash.each{|k,v| @initial_subject_term_hash[k] = true }
    
    # puts "@subjectTermHash has been initialized to:  #{@subjectTermHash.keys.join(", ")}"
    
    # Add every "valid search term" available for our subject terms into @searchTermHash
    @subjectTermHash.each_key do |subject_term|
      if @@validSearchTermHash.has_key? subject_term
        @@validSearchTermHash[subject_term].each{|t| @searchTermHash[t] = 0}
      end
    end
    # puts "@searchTermHash has been initialized to:  #{@searchTermHash.keys.join(", ")}"
  end
  
  def search
    # Initialize last and current journal counts for iteration step
    searchTermThreshold = @@searchTermThresholdStart
    lastJournalCount    = nil
    currentJournalCount = 0
    lastJournalList     = {}
    lastSearchTermList  = {}
    # lastJournalList     = @nlmJournalList # These will be used at some point in the future
    # lastSearchTermList  = @searchTermHash # when there is some intelligence built in
    
    # Iterate as long as new journals are being retrieved
    while lastJournalCount != currentJournalCount
      currentJournalCount = @nlmJournalList.size
      
      # Update last journal count,
      # and if the same as the current count, next to exit loop
      lastJournalCount = currentJournalCount unless lastJournalCount.nil?
      
      next if lastJournalCount == currentJournalCount
      
      # Initiate journal list using subject terms
      # (including those that might have come from the pmid)
      getJournalsFromSubjectTerms
      updateSubjectTermsFromJournalList
      
      searchJournalCount = lastJournalCount.to_i
      
      # Get additional search terms based on journal titles
      searchTermThreshold -= @@searchTermThresholdDecrement
      # puts "getting terms at threshold: #{searchTermThreshold}"
      getSearchTerms(searchTermThreshold)
      
      # Add subject terms to general search terms
      @subjectTermHash.each_key do |subjectTerm|
        searchTermHash[subjectTerm.downcase] = 1
      end
      
      # Get additional journals using search terms
      getJournalsFromSearchTerms
      updateSubjectTermsFromJournalList
      searchJournalCount = @nlmJournalList.size
      
      # @nlmJournalList = lastJournalList # This will be used at some point in the future when there is some intelligence built in. See above
      # @subjectTermHash = lastSearchTermList
      
      lastJournalCount = @nlmJournalList.size
    end
    
    @nlmJournalList.values
  end
  
  private 
  
  # get list of nlm journal ids based on subject terms
  def getJournalsFromSubjectTerms
    # puts "  ... Retrieving journal identifiers using journal subject terms ..."
   subjectTermList = []

   # create query for all subject entry terms in subjectTermHash
   @subjectTermHash.each_key do |entryTerm|    

     # map entryTerm to journal subjectTerm
     subjectTerms = []
      entryTerm = denormalize_subject_term(entryTerm)
      if @@validSearchTermHash.has_key? entryTerm
        subjectTerms = @@validSearchTermHash[entryTerm]
      end

      # puts "    ... Mapped entry term (#{entryTerm}) -to-> journal subject term(s) (#{subjectTerms.join(', ')}) ..."

      # append subject terms to the main list
      subjectTermList += subjectTerms
    end
    
    # subjectTerm = subjectTerm.gsub(/\(/,"\\(").gsub(/\)/,"\\)")
    # subjectTermList += "\"#{subjectTerm}\"\\[st\\]+OR+"
    
    subjectTermString = subjectTermList.collect{|t| url_escape_subject_term(t)}.join("+OR+")

    # run query to entry and get the query and webenv variables    
    url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&usehistory=y&retmax=0&term=(#{subjectTermString})+AND+(serial%5BItem+Type%5D+AND+nlmcatalog+pubmed%5Bsb%5D)"
    # puts %(curl --silent "#{url}")
    entrezResults = `curl --silent "#{url}"`
        
    entrezResults[/<QueryKey>(.*)<\/QueryKey>/] 
    query_key = $1

    entrezResults[/<WebEnv>(.*)<\/WebEnv>/] 
    web_env = $1


    # puts "WebEnv: #{web_env}", "QueryKey: #{query_key}"
    # get each journal's details
    getJournalDetails(query_key, web_env)
  end
  
  
  # get required journal details based on nlm ids (for those ids with not details)
  # RMS - I added the get_nlm_ids_using_journal_ids instead of setting and testing for 
  #       a query_key and web_env that were 0, because I thought that might be dangerous
  def getJournalDetails(query_key, web_env)
    # puts "  ... Getting journal details ..."

    journalDetails = `curl --silent "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nlmcatalog&query_key=#{query_key}&WebEnv=#{web_env}&retmode=text"`

    # puts journalDetails[0,10] + "..."

    # extract out the title, abbrv title, and subject terms for each journal
    stFlag = 0
    tiFlag = 0
    journalSubjectTerms = Hash.new
    journalTitle = ""
    journalAbbrTitle = ""
    journalISSN = ""

    journalDetails.each do |listingLine|   

      # get title abbreviation
      if listingLine =~ /^Title Abbreviation: (.*)/
        journalAbbrTitle = $1 
        stFlag = 0
      end

      # get wrapped title line (if exists)
      if tiFlag == 1 && listingLine !~ /:/
        listingLine.chomp!
        journalTitle += " #{listingLine}"
        tiFlag = 0
      end

      # get full title
      if listingLine =~ /^Title: (.*)/
        journalTitle = $1.chomp
        stFlag = 0
        tiFlag = 1
      end 

      # get ISSN
      if listingLine =~ /^ISSN: ([^(]*)\s/
        journalISSN = $1
      end

      # get additional subject terms
      if stFlag == 1 && listingLine !~ /:/
        newTerm = listingLine
        # puts "---> #{newTerm}"

        if newTerm != nil
          newTerm = newTerm.gsub(/^\s+/,"")
          newTerm.chomp! 
          journalSubjectTerms[newTerm] = "st"
        end
      end

      # get first subject term
      if listingLine =~ /^Subject Term\(s\): (.*)/
        journalSubjectTerms[$1] = "st"
        # puts "st--> #{$1}"
        stFlag = 1
      end

      # get nlm id
      if listingLine =~ /^NLM ID: (.*)/

        nlmJournalId = $1
        journal_id = nlmJournalId.chomp('R').to_i
        
        stFlag = 0
        tiFlag = 0
        journalSubjectTermsList = ""
        journalSubjectTerms.each_key do |subjectTerm|
          journalSubjectTermsList += "#{subjectTerm},"
        end
        journalSubjectTermsList = journalSubjectTermsList.gsub(/,$/,"")

        if nlmJournalId != ""
          journal        = Journal.new
          journal.id     = journal_id
          journal.nlm_id = nlmJournalId
          journal.title  = journalTitle
          journal.issn   = journalISSN
          journal.title_abbreviation = journalAbbrTitle
          journal.nlm_search_subject_terms = journalSubjectTermsList # This is causing a bug in the rails code because there's a AR association named subject_terms
          journal.rank   = calculateRank(journalSubjectTermsList.split(/,/))
          
          # Check if a journal exists in journals table and if not, save it. 
          # The has_key? bit keeps the database from getting unnecessarily slammed
          # on multiple iterations of the algorithm
          unless @nlmJournalList.has_key?(nlmJournalId) || Journal.exists?(journal_id)
            journal.save
          end
          
          @nlmJournalList[nlmJournalId] = journal 
        end    

        journalSubjectTerms.clear
      end
    end
  end
  
  #            # of journal's search terms that match the users
  # Rank =  ------------------------------------------------------
  #                     # of journal search terms
  def calculateRank(subject_terms)
    if subject_terms.length < 1
      return -1.0
    else
      # puts "Journal Subject Terms: #{subject_terms.join ', '}"
      # puts "Initial Subject Terms: #{@initial_subject_term_hash.keys.join ', '}"
      matches = 0.0
      denominator = subject_terms.length.to_f # [subject_terms.length, @initial_subject_term_hash.length].max.to_f
    
      subject_terms.each do |term|
        matches += 1.0 if @initial_subject_term_hash.has_key?(normalize_subject_term(term))
      end
    
      # puts "  Rank: #{matches / denominator}"
    
      matches / denominator
    end
  end
  
  # update subject terms from nlm journal list...
  def updateSubjectTermsFromJournalList
    # puts "Journal Count = #{@nlmJournalList.size}"

    stCandidateHash = Hash.new

    @nlmJournalList.each do |nlmIdKey,journalListing|
      # puts journalListing
      # puts "NLMID --> #{nlmIdKey} --> #{journalListing}"
      nlmId = journalListing.nlm_id
      fullTitle = journalListing.title
      issn = journalListing.issn
      abbrTitle = journalListing.title_abbreviation
      keywords = journalListing.nlm_search_subject_terms

      if keywords != nil
        keywords.split(/,/).each do |subjectTerm|
          subjectTerm = subjectTerm.gsub(/\s/,"\+")
          # puts "---->>> #{subjectTerm}"
          if !(stCandidateHash.has_key?(subjectTerm))
            stCandidateHash[subjectTerm] = 1
          else
            stCandidateHash[subjectTerm] += 1
          end
        end
      end
    end

    # go through the possible new subject terms
    # -- only keep those that occur in at least the threshold amount
    threshold = @@subjectTermThreshold # 0.125  RMS - Moved this into a class var
    stCandidateHash.each do |stCandidate,stFreq|

      if stFreq > (nlmJournalList.size * threshold)
        if !(@subjectTermHash.has_key?(stCandidate))
          @subjectTermHash[normalize_subject_term(stCandidate)] = 0 # RMS added call to normalize_subject_term instead of calling stCandidate.downcase
        end
      end
    end    
  end
  
  # From the journal titles, get additional search terms
  def getSearchTerms(thresholdValue)
    # puts "... Deriving additional search terms from journal title information ..."

    fullTitleWordHash = Hash.new
    abbrTitleWordHash = Hash.new

    newSearchTermList = Hash.new

    @nlmJournalList.each_value do |journalListing|
      nlmId = journalListing.nlm_id
      fullTitle = journalListing.title
      issn = journalListing.issn
      abbrTitle = journalListing.title_abbreviation
      keywords = journalListing.nlm_search_subject_terms
      # puts "* #{journalListing} "

      if fullTitle != nil
        fullTitle.split(/\s+/).each do |word|
          word = word.gsub(/[^A-Za-z]/,"")
          if !(@@stopWordHash.has_key?("#{word.downcase}")) && word.size > 1
            # puts "word--> #{word.downcase}" 
            if !(newSearchTermList.has_key?(word.downcase))
              newSearchTermList[word.downcase] = 1
            else
              newSearchTermList[word.downcase] += 1
            end
          end
        end  
      end

      if abbrTitle != nil
        abbrTitle.split(/\s+/).each do |word|
          word = word.gsub(/[^A-Za-z]/,"")
          if !(@@stopWordHash.has_key?("#{word.downcase}")) && word.size > 1
            # puts "word--> #{word.downcase}" 
            if !(newSearchTermList.has_key?(word.downcase))
              newSearchTermList[word.downcase] = 1
            else
              newSearchTermList[word.downcase] += 1
            end
          end
        end
      end

    end

    newSearchTermList.each_key do |newSearchTerm|
      # puts "*** #{newSearchTerm} = #{newSearchTermList[newSearchTerm]}" if newSearchTermList[newSearchTerm] >= (thresholdValue * nlmJournalList.size)
      if newSearchTermList[newSearchTerm] >= (thresholdValue * @nlmJournalList.size)
        if !(@searchTermHash.has_key?(newSearchTerm))
          @searchTermHash[newSearchTerm] = 0
        end
      end
    end 
  end
  
  def getJournalsFromSearchTerms
   # puts "  ... Retrieving journal identifiers using search terms ..."

   searchTermList = ""

   # go through subjectTermHash and only process new terms (flag == 0)
   @searchTermHash.each_key do |searchTerm|    
        searchTerm = searchTerm.gsub(/\(/,"\\(").gsub(/\)/,"\\)")
        searchTermList += "\"#{searchTerm}\"\\[All+Fields\\]+OR+"
    end


    url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&usehistory=y&retmax=0&term=(#{searchTermList})+AND+(serial%5BItem+Type%5D+AND+nlmcatalog+pubmed%5Bsb%5D)"
    # puts url
    entrezResults = `curl --silent "#{url}"`

    entrezResults[/<QueryKey>(.*)<\/QueryKey>/] 
    query_key = $1

    entrezResults[/<WebEnv>(.*)<\/WebEnv>/] 
    web_env = $1

    # puts '!!!!!!!!!!!', entrezResults, '!!!!!!!!!!!!!!!!'


    getJournalDetails(query_key, web_env)
  end
  
  # Converts "Medical Informatics" into "medical+informatics"
  def normalize_subject_term(term)
    term.strip.tr(' ', '+').downcase
  end
  
  # Converts "medical+informatics" into "medical informatics"
  def denormalize_subject_term(term)
    term.tr('+', ' ')
  end
  
  # Wraps term in quotes, escapes parenthasis, -and-appends-[st]- (not anymore)
  def url_escape_subject_term(term)
    term = normalize_subject_term(term)
    term = CGI.escape(term) 

    term
  end
  
end