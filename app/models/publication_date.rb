class PublicationDate < ActiveRecord::Base
  belongs_to :query, :polymorphic => true
end
