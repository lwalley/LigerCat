class PublicationDate < ActiveRecord::Base
  belongs_to :query, :polymorphic => true

  validates_presence_of :query_id
  validates_numericality_of :year, :publication_count
  
  attr_accessible :query_id, :year, :publication_count
end
