class KeywordFrequency < ActiveRecord::Base
  self.abstract_class = true
  
  # This is a normalization function to drop terms like "Humans" out of the tag clouds
  # def weighted_frequency
  #   @weighted_frequency ||= frequency - (frequency * score.to_f)
  # end
end