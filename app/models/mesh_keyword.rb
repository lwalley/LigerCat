class MeshKeyword < ActiveRecord::Base
  has_many :journal_mesh_frequencies
  has_many :journals, :through => :journal_mesh_frequencies
  
  has_many :pubmed_mesh_frequencies
  has_many :pubmed_queries, :through => :pubmed_mesh_frequencies
  
  has_many :blast_mesh_frequencies
  has_many :blast_queries, :through => :blast_mesh_frequencies

  class << self
    # Selects all the MeshKeywords in the local database given a 
    # a pubmed id by joining the pmids_mesh_keywords table
    def find_all_by_pmid(pmid)
      sql = 'SELECT mesh_keywords.* FROM mesh_keywords INNER JOIN pmids_mesh_keywords ON pmids_mesh_keywords.mesh_keyword_id = mesh_keywords.id '
      sql <<  if pmid.is_a? Array
                ' WHERE pmids_mesh_keywords.pmid IN(?)'
              else  
                ' WHERE pmids_mesh_keywords.pmid = ?'
              end
      find_by_sql([sql, pmid])
    end
  end
  
  def to_i
    read_attribute(:id).to_i
  end
end
