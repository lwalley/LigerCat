class JournalTextFrequency < KeywordFrequency
  belongs_to :journal
  belongs_to :text_keyword
  
  # This is analagous to calling Journal.text_frequencies, but to be used
  # with multiple journal ids
  def self.find_frequencies_for_journals(journals, options={})
    options[:order] ||= 'name ASC'
    query = "SELECT text_keywords.name AS name, SUM(journal_text_frequencies.frequency) AS frequency, text_keywords.score AS score " +
            "FROM journal_text_frequencies INNER JOIN text_keywords ON journal_text_frequencies.text_keyword_id = text_keywords.id " +
            construct_where(journals) +
            "GROUP BY text_keywords.id " +
            "ORDER BY #{options[:order]}"
    find_by_sql(query)
  end
  
  private 
  def self.construct_where(journals)
    if !journals.is_a?(Array)
      return "WHERE (journal_text_frequencies.journal_id = '#{journals.to_i}') "
    elsif journals.length == 1 
      return "WHERE (journal_text_frequencies.journal_id = '#{journals.first.to_i}') "
    else
      journals = journals.map {|j| "'#{j.to_i}'" }
      return "WHERE (journal_text_frequencies.journal_id IN (#{journals.join(',')})) "
    end
  end
  
end
