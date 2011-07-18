class MeshSearch < NLMEutilSearch
  attr_accessor :terms
  
  def initialize(options={})
    options = options.merge({:db => 'pubmed', :retmode => 'xml'})
    super(options)
  end
  
  def efetch_url
    "#{@@eutils_base_url}/efetch.fcgi?db=#{@db}&retmode=#{@retmode}&rettype=pubmed&id=#{@terms.join(',')}"
  end
  
  def terms=(t)
    t = [t] unless t.is_a? Array
    @terms = t
  end
  
  def query_eutils(pmids)
    self.terms = pmids
    efetch
  end
  
  def parse_efetch_response(response_body)
    @results = {}
    @terms.each{|t| @results[t] = []} # initialize the keys to the search terms, and values to empty arrays
    
    current_article = nil
    
    response_body.each_line do |line|
      case line
      when /<PMID>(.*)<\/PMID>/
        current_article = $1.to_i rescue $1
      when /<DescriptorName MajorTopicYN=".">(.*)<\/DescriptorName>/
          @results[current_article] << $1 rescue nil
      end
    end
    
    return @results
  end
end