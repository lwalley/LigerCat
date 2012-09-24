#
# The MIT License
# 
# Copyright (c) 2008 Christian Bryan
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# downloader.rb
# 
# An easy HTTP downloader for Ruby.
#
# Christian Bryan
# christianbryan@gmail.com
# November 27, 2008
#
# Ryan Schenk
# rschenk@mbl.edu
# Feb 13, 2009
#

require 'open-uri'
require 'net/http'
require 'fileutils'

class Downloader
  
  USER_AGENT = "Crankstation"
  CHUNK_SIZE = 500000
  
  attr_accessor :url, :browser, :content_length
  
  def initialize(url)
    @url, @browser = initialize_with_redirects(url)
    @content = ""
  end
  
  # Recursively follows redirects and handles HTTPS,
  # and returns url, http when done
  def initialize_with_redirects(url, limit=5)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.instance_of? URI::HTTPS
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    response = http.request_head(uri.path)
    if response.kind_of?(Net::HTTPRedirection)
      redirect_url = response['location']
      return initialize_with_redirects(redirect_url, limit - 1) # Recurse 
    else
      return [uri, http]
    end
  end
  
  def download(start = 0, stop = content_length, length = CHUNK_SIZE, &block)
    if content_length == 0
      raise Exception.new("Content length is nil!")
      return
    end
    
    start.step(stop, length) do |n|
      data = fetch_chunk(n, n + length - 1) # RMS
      yield( (n+length-1) >= content_length ?  1.0 : (n+length-1)/content_length.to_f ) if block_given? # RMS
      append_content data # RMS
    end
  end

	def append_content(data) # RMS
		@content << data
	end
  
  def content_length
    @content_length ||= @browser.head(@url.path)['content-length'].to_i
  end
  
  def fetch_chunk(start, stop)
    response = @browser.request_get(@url.path, { "Range" => "bytes=#{start}-#{stop}" })
    response.value
    response.body
  end
end

#
# Writes each chunk to a File instead of storing it in memory
#
class FileDownloader < Downloader
  attr_accessor :filename, :path
  
	def initialize(url, path='')
		super(url)
		@filename = @url.path[%r{[^/]+\z}]
    @path = path
		@file = nil
	end
	
  def download(start = 0, stop = content_length, length = CHUNK_SIZE, &block)
    FileUtils.mkdir_p(path)
		@file = File.open(path_to_file, 'w')
		super(start, stop, length, &block)
		@file.close
    @file
	end
	
	def append_content(data)
		@file.syswrite(data)
	end
  
  def path_to_file
    @path_to_file ||= File.join(path,filename)
  end
end
