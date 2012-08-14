class KeywordFrequency < ActiveRecord::Base
  self.abstract_class = true
  
  attr_accessible :weighted_frequency, :mesh_keyword_id, :frequency
end