class PublicationDate < ActiveRecord::Base
  belongs_to :query, :polymorphic => true

  validates_presence_of :query_id, :query_type
  validates_numericality_of :year, :publication_count
  
  attr_accessible :query_id, :query_type, :year, :publication_count
end
