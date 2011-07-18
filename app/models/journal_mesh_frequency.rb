class JournalMeshFrequency < KeywordFrequency
  belongs_to :journal
  belongs_to :mesh_keyword, :foreign_key => "mesh_id"
  
  # This is analagous to calling Journal.mesh_frequencies, but to be used
  # with multiple journal ids
  def self.find_frequencies_for_journals(journals, options={})
    options[:order] ||= 'name ASC'
    query = "SELECT mesh_keywords.name AS name, SUM(journal_mesh_frequencies.frequency) AS frequency, mesh_keywords.score AS score " +
            "FROM journal_mesh_frequencies INNER JOIN mesh_keywords ON journal_mesh_frequencies.mesh_id = mesh_keywords.id " +
            construct_where(journals) +
            "GROUP BY mesh_keywords.id " +
            "ORDER BY #{options[:order]}"
    find_by_sql(query)
  end
  
  private 
  def self.construct_where(journals)
    if !journals.is_a?(Array)
      return "WHERE (journal_mesh_frequencies.journal_id = '#{journals.to_i}') "
    elsif journals.length == 1 
      return "WHERE (journal_mesh_frequencies.journal_id = '#{journals.first.to_i}') "
    else
      journals = journals.map{|j| "'#{j.to_i}'" }
      return "WHERE (journal_mesh_frequencies.journal_id IN (#{journals.join(',')})) "
    end
  end
end
