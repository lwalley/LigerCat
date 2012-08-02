# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def context    
    context ||=    case controller_name
                    when "pubmed_queries", "eol", "static" then "pubmed_queries"
                    when "journal_queries", "journals"     then "journals"
                    else  controller_name
                    end
  end
  
  def title
    # query is a helper method defined in the articles and eol controllers
    query.blank? ? 'LigerCat' : awesome_truncate(query) + ' - LigerCat' rescue 'LigerCat'
  end
  
  def body_id
    @body_id || "#{controller.controller_name}_#{action_name}"
  end
  
	# Used when clicking on the logo to return the user
	# home, based on their current context
	def context_home_url 
		self.send "#{context}_url" rescue root_url
	end
	#
	# Navigation tabs and contents
	#
	def nav_tab(name, url)
    active_class = (context == name) ? ' active' : ''

    
    html =  "<li class='#{name + active_class}'>"
    html << link_to_unless(context == name, name.titleize, url){|text| "<span class='active'>#{text}</span>".html_safe }
    html << '</li>'
    
    html.html_safe
	end
	
	# This adds the "hint" text to the search fields.
	def searchbox_hint_javascript
	  case context
	  when 'journals' then "TextBoxHint.add('journals_q', 'Enter One or More Terms to Search NLM Journals');"
    when 'articles' then "TextBoxHint.add('articles_q', 'Enter One or More Terms to Search PubMed');"
    when 'genes'    then "TextBoxHint.add('genes_q',    '> Paste in one FASTA-formatted sequence to BLAST');"
    end
	end

  def articles_text_field_tag(query_string)
		contextualized_text_field_tag(query_string, 'articles')
	end
	
	def journals_text_field_tag(query_string)
		contextualized_text_field_tag(query_string, 'journals')
	end
	
	def contextualized_text_field_tag(query_string, context)
		contents = query_string if context == context
		text_field_tag :q, contents, {:class => 'text searchbox', :id => "#{context}_q"}
	end
	
	def genes_text_area_tag(query_string, html_options={})
    text_area_content = query_string || ''
    html_options = {:id => 'genes_q', :rows => '1', :cols => '12', :class => ''}.merge(html_options)
    html_options[:class] << 'textarea searchbox'
    text_area_tag(:q, text_area_content, html_options)
  end
  
  # type should be :mesh or :text and is used to define the javascript selection function
  def keyword_cloud(keywords, type, options={})
    options = {:classes => %w(not-popular somewhat-popular popular quite-popular very-popular), :partial => 'shared/keyword', :no_keywords_partial => 'shared/no_keywords'}.merge(options)
    
    classes = options[:classes]
    
    # Sometimes non-existent MeSH IDs can get inserted into Redis.
    # This can happen when NLM changes its MeSH headings, and then back-updates the catalogue.
    # As the MESH database is updated periodically, these kinks will work themselves out,
    # but we must have this line here to account for the lag between updating the MeSH database
    # and said kinks working themselves out
    keywords.delete_if{|k| (! k.name) rescue true }
    
    max, min = 0, 0x7FFFFFF # A really big fixnum!
    keywords.each do |t|
      next if t.name == 'Animals'
      f = t.weighted_frequency
      max = f if f > max
      min = f if f < min
    end
    
    divisor = (max - min) / classes.size.to_f
    
    String.new.tap do |keyword_list|
      keywords.each do |t|
        next if t.name == 'Animals'
        
        class_rank = if t.weighted_frequency == max
                       classes.size - 1
                     else
                       ((t.weighted_frequency - min) / divisor).floor
                     end
                             
        css_class = classes[class_rank]
        if t.frequency > 0
          keyword_list << render(:partial => options[:partial], :locals => {:name => t.name, :frequency => t.frequency, :css_class => css_class, :type => type}) unless class_rank < 1 && type == :text
        end
      end
      keyword_list << render(:partial => options[:no_keywords_partial], :locals => {:type => type}) if keyword_list.blank?
    end
  end
  
	def eol_mesh_keyword_cloud(keywords, options={})
    options = {:partial => 'eol/keyword', :no_keywords_partial => 'eol/no_keywords'}.merge(options)
    mesh_keyword_cloud(keywords, options)
	end
	
	def embedded_mesh_keyword_cloud(keywords, options={})
    options = {:partial => 'articles/embedded_keyword', :no_keywords_partial => 'articles/no_keywords'}.merge(options)
    mesh_keyword_cloud(keywords, options)
	end

  def mesh_keyword_cloud(keywords, options={})
    keyword_cloud(keywords, :mesh, options)
  end
  
  def text_keyword_cloud(keywords, options={})
    keyword_cloud(keywords, :text, options)
  end
  
  def pagination_results(paginator)
    p_total = paginator.total_entries
    p_start = paginator.offset + 1
    p_end   = ((paginator.offset + paginator.per_page) > p_total) ? p_total : paginator.offset + paginator.per_page
    "<span class='page_start'>#{p_start}</span>&ndash;<span class='page_end'>#{p_end}</span> of <span class='results_total'>#{p_total}</span>"
  end
  
  def little_spinner(options={})
    options = {:text => 'Loading...', :show_text => true, :display => 'none'}.merge(options)
    loading = (options[:show_text]) ? options[:text] : ''
    "<span class=\"little_spinner\" style=\"display:#{options[:display]}\">#{loading}</span>"
  end
  
  def token_tag_with_id
    unless protect_against_forgery?
      ''
    else
      tag(:input, :type => "hidden", :id=> 'authenticity_token', :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end
  end
  
  def journal_dom_id(j)
    "journal_#{journal_id(j)}"
  end
  
  def checkbox_dom_id(journal)
    "checkbox_#{journal_id(journal)}"
  end
  
  def selection_dom_id(journal)
    "selection_#{journal_id(journal)}"
  end
  
  def journal_id(j)
    j.nlm_id
  end
  
  # Helper for making XHTML/CSS bar graphs
  # http://applestooranges.com/blog/post/css-for-bar-graphs/?id=55
  def bar_graph(name, value, html_options={})
    html_options.has_key?(:class) ? html_options[:class] << ' bargraph' : html_options[:class] = 'bargraph'
    
    content_tag(:div, 
      content_tag(:strong, 
        content_tag(:span, "#{value}%"),
      :style => "width: #{value}%;", :title => h(name.to_s.humanize), :class => 'bar'), # options for :strong tag
    html_options) # options for :div tag
  end
  
  def publication_histogram(histohash, query=nil)
    min_year = histohash.keys.min
    max_year = histohash.keys.max
    # We are NOT going to show the current year, because the publication counts will be instantly outdated
    max_year -= 1 if max_year == Time.now.year
    
    max_counts = histohash.values.max
    
    width =  100.0 / (max_year - min_year + 1)
    
    size_class = case max_year - min_year
                 when  0...23  then 'small'
                 when 23...70  then 'medium'
                 when 70...150 then 'large'
                 else               'huge'
                 end
    
    haml_tag :ul, {:id => 'publication_timeline', :class => "timeline #{size_class}"} do
      min_year.upto(max_year) do |year|
        count = histohash[year]
        height = count * 100 / max_counts
        
        # Unfortunately, it's impossible for us to directly link the gene-based histogram to any given
        # pubmed search. In that case, the query param above will be nil, and we'll just return false
        # when a user clicks on the link. Crappy solution, but best I could come up with right now
        link_opts ={}
        if query
          link_opts[:href] = 'http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=Search&term=' + CGI::escape("(#{query}) AND (\"#{year}\"[PDAT])")
          link_opts[:target] = '_blank'
          link_opts[:onclick] = 'return false;' if count == 0
        else
          link_opts[:href] = '#publication_timeline'
          link_opts[:onclick] = 'return false;'
        end
        
        classes = []
        classes << 'n20' if year % 20 == 0
        classes << 'n10' if year % 10 == 0
        classes << 'n5'  if year % 5 == 0
        classes << 'n2'  if year % 2 == 0
        classes << 'z'   if count == 0
            
        haml_tag :li, :class => classes.join(' '), :style => "width: #{width}%" do
          haml_tag :a, link_opts do
            haml_tag :span, year,  :class => 'year'
            haml_tag :span,        :class => 'bar', :style => "height: #{height}%" do
              haml_tag :span, count, :class => 'count'
            end
          end
        end
      end
    end

  end
  
  
  # Awesome truncate
  # First regex truncates to the length, plus the rest of that word, if any.
  # Second regex removes any trailing whitespace or punctuation (except ;).
  # Unlike the regular truncate method, this avoids the problem with cutting
  # in the middle of an entity ex.: truncate("this &amp; that",9)  => "this &am..."
  # though it will not be the exact length.
  def awesome_truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.mb_chars.length
    text.mb_chars.length > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end


  # I made this a helper instead of using the numerous Google Analytics
  # plugins, because the ones I tried freaked out when I was using action caching
  def google_analytics
    tracking_code = 'UA-9666905-1'
    environments  = ['production']
    
    if environments.include?(Rails.env)
      returning String.new do |html|
        html << "<script src='http://www.google-analytics.com/ga.js' type='text/javascript'></script>"
        html << "<script type='text/javascript'>try{var pageTracker = _gat._getTracker('#{tracking_code}'); pageTracker._trackPageview();} catch(err) {}</script>"
      end
    end
  end
  
  def image_link(img_src, url, img_html_options)
    link_to(image_tag(img_src, img_html_options), url, :class=>"img_link external_link", :target=>'_blank')
  end
  
  def insert_big_footer
    content_for :footer do
      render(:partial=>'shared/big_footer', :locals => {:footer_class => context})
    end
  end
end

