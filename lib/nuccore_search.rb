require 'nlm_eutil_search'
class NuccoreSearch < NLMEutilSearch
  def initialize(options={})
    options = options.merge({:db => 'nuccore', :usehistory => 'n', :retmax => 1000000})
    super(options)
  end
  
  private
  
  def query_eutils(terms)
    esearch(terms)
  end
  
  def parse_esearch_response(response_body)
    @results = []
    
    response_body.each_line do |line|
      case line
      when /<Count>(.*)<\/Count>/
        @count = $1.to_i rescue $1
      when /<Id>(.*)<\/Id>/
        @results << $1
      end
    end
    
    return @results
  end
end