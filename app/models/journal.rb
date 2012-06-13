class Journal < ActiveRecord::Base
  has_many :results, :dependent => :destroy
  has_many :queries, :through => :results
  
  has_many :subject_terms, :through => :journal_classifications
  
  has_many :journal_mesh_frequencies
  has_many :mesh_keywords, :through => :journal_mesh_frequencies
  
  has_many :journal_text_frequencies
  has_many :text_keywords, :through => :journal_text_frequencies
  
  attr_accessor :nlm_search_subject_terms # Virtual attribute used on the NLM search algorithm
  attr_accessor :rank
  
  def title_abbreviation
    read_attribute(:title_abbreviation) || read_attribute(:title)
  end
  
  # mesh_frequencies and text_frequencies provide a common interface for accessing mesh and text keywords with optimized SQL.
  # They are not DRY in the least, because of one stupidly named column. Damn.
  def mesh_frequencies(options={})
    options[:order] ||= 'name ASC'
    journal_mesh_frequencies.find_by_sql(["SELECT journal_mesh_frequencies.frequency AS frequency, mesh_keywords.name AS name, mesh_keywords.score AS score FROM journal_mesh_frequencies, mesh_keywords WHERE (journal_mesh_frequencies.journal_id = ?) AND (mesh_keywords.id = journal_mesh_frequencies.mesh_id) order by #{options[:order]};", self.id])
  end
  
  def text_frequencies(options={})
    options[:order] ||= 'name ASC'
    journal_text_frequencies.find_by_sql(["SELECT journal_text_frequencies.frequency AS frequency, text_keywords.name AS name, text_keywords.score AS score FROM journal_text_frequencies, text_keywords WHERE (journal_text_frequencies.journal_id = ?) AND (text_keywords.id = journal_text_frequencies.text_keyword_id) order by #{options[:order]};", self.id])
  end
  
  def before_create
    self.new_journal = true
  end
  
  # We're going to use full NLM ids in the URLS, and since our PK's are
  # the integerized version of an NLM id, we don't have to do any de-converting!
  # This works because .find will call .to_i on any ids passed to it.
  #   Ex: "12345R".to_i --> 12345, "0000201".to_i --> 201
  def to_param
    self.nlm_id
  end
end
