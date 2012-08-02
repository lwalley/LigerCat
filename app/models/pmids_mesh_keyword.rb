# This lame little class is used only in PubmedQuery#perform_query! to
# insert more rows into the lame little pmids_mesh_keywords table

class PmidsMeshKeyword < ActiveRecord::Base

  belongs_to :mesh_keyword

  attr_accessible :pmid, :mesh_keyword_id

  class << self
    def bulk_insert(pmid, mesh_keyword_ids)
      mesh_keyword_ids = [mesh_keyword_ids] unless mesh_keyword_ids.is_a? Array
      mesh_keyword_ids = mesh_keyword_ids.map{|mk| mk.id} if mesh_keyword_ids.first.is_a? ActiveRecord::Base
      create(mesh_keyword_ids.map{|mk_id| {:pmid => pmid, :mesh_keyword_id => mk_id} })
    end
  end
end
