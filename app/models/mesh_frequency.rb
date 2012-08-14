class MeshFrequency < ActiveRecord::Base
  belongs_to :query
  belongs_to :mesh_keyword

  attr_accessible :weighted_frequency, :mesh_keyword_id, :frequency, :query_id

  def name
    @name ||= mesh_keyword.name
  end
end
