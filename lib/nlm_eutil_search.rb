# This is a base class providing most functionality to perform an esearch
# and efetch from NLM. You WILL need to subclass this for your specific
# application. 
# 
# In most cases, you'll only need to implement parse_efetch_response. 
# 
# I could not implement that method here because the response is so
# radically different depending on the chosen database. 

require 'net/http'

class NLMEutilSearch
  attr_accessor :retmax, :usehistory, :term, :db, :retmode, :skip_sleep
  attr_reader   :results, :count
  
  @@eutils_base_url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
  
  # Options are used in the URLs to esearch and efetch. They should look familiar.
  #
  # When you subclass, you will want your initialize method to provide the db option!!
  def initialize(options = {})
    @retmax     = options[:retmax]     || 0
    @usehistory = options[:usehistory] || 'y'
    @db         = options[:db]         || nil
    @retmode    = options[:retmode]    || 'xml'
  end
  
  # Behaves just like search!, but catches any error, returning false if an error occurs.
  def search(terms)
    # Perform a search!, rescuing any error and returning false
    search!(terms) rescue false
  end
  
  # Returns the results from querying eutils or an empty array
  def search!(terms)    
    unless @results = query_eutils(terms)
      @results = []
    end
    
    @results
  end
  
  private
  
  # Performs the usual esearch/efetch dance. 
  # Notice that esearch returns the Count field, and only
  # performs the efetch if the Count is greater than 0.
  #
  # In some cases, though, you might not ever need to use efetch.
  # In that case, simply overload this method to your desired behavior
  def query_eutils(terms)
    if esearch(terms).to_i > 0 
      efetch
    end
  end
  
  # Sends out an http POST to esearch
  # We use POST here instead of GET in case the terms are huge. 
  #
  # To play nicely with query_eutils, this method should return the count.
  # However, if you are overloading query_eutils, that might not be necessary,
  # for instance if your application does not require efetch, and can get everything
  # from esearch with a high retmax.
  #
  # Notice this method calls parse_esearch_params and returns its value. That's
  # where you want to do your overloading. 
  def esearch(terms)
    raise 'Must define db attribute' unless @db
    
    do_sleep
    url = @@eutils_base_url + '/esearch.fcgi'
    params = esearch_params(terms) # you can overload esearch_params() if you want
    response = Net::HTTP.post_form( URI.parse(url), params )
    
    parse_esearch_response(response.body)
  end
  
  
  # Peforms an efetch request. 
  # 
  # Please note that parse_efetch_reponse is only stubbed out at this point.
  # You will need to overload it for your particular database and retmode!
  def efetch
    do_sleep
    url = efetch_url # you can overload this method if you want/need
    response = Net::HTTP.get_response(URI.parse(url))
    parse_efetch_response(response.body)
  end


  # This method parses the response body from the esearch request using a regular expression.
  # A regex is often much faster than parsing the document as XML, especially if your retmax is large.
  #
  # It sets the @query_key, @web_env, and @count.
  #
  # Return the @count!!!!!
  #
  # When you are subclassing NLMEutils for a special purpose, you may find yourself
  # overloading this method. For instance, if you set retmax > 0, you would want to 
  # overload this method to parse the results.
  def parse_esearch_response(response_body)
    @query_key = @web_env = @count = nil
    
    # Loop through each line of the response body, try to match QueryKey, WebEnv, and Count
    response_body.each_line do |line|
      case line
      when /<QueryKey>(.*)<\/QueryKey>/
        @query_key = $1
      when /<WebEnv>(.*)<\/WebEnv>/
        @web_env = $1
      when /<Count>(.*)<\/Count>/
        @count = $1
      end
    end
    
    if @query_key && @web_env && @count
      return @count
    else
      raise 'Could not extract QueryKey, WebEnv, and Count from eSearch response'
    end
  end
  
  
  # This method parses the response body from the efetch request.
  # If you are subclassing NLMEutils, you MUST define this method
  #
  # Return an array of results
  def parse_efetch_response(response_body)
    raise 'You must define parse_efetch_response or redefine query_eutils in your subclass!'
  end

  # The POST params sent by esearch. 
  def esearch_params(terms)
    {'db' => @db, 'usehistory'=> @usehistory, 'retmax' => @retmax, 'term' => terms}
  end
  
  # The GET url sent by efetch.
  def efetch_url
    "#{@@eutils_base_url}/efetch.fcgi?db=#{@db}&WebEnv=#{@web_env}&query_key=#{@query_key}&retmode=#{@retmode}"
  end
  
  def do_sleep
    sleep(3) unless @skip_sleep || Rails.env.test?
  end
end