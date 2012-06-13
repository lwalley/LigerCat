# Due to AJAX security restrictions, this controller is simply a middleman for 
# http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&usehistory=y&retmax=0&term=<YOUR TERM(S) HERE>

class PubmedCountsController < ApplicationController

  # GET /pubmed_count
  def show
    if params[:term].blank?
       head :no_content
    else
       url = URI.parse('http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&usehistory=y&retmax=0&term=' << CGI::escape(params[:term])) #.gsub(/\s+/, '+'))
       response = Net::HTTP.start(url.host, url.port) do |http|
         http.get(url.request_uri)
       end
       response.body[/<Count>(.*)<\/Count>/] 
       count = $1
       render :text => count, :status => :ok
    end
  end
end
