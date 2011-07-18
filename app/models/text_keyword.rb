class TextKeyword < ActiveRecord::Base
  has_many :journal_text_frequencies
  has_many :journals, :through => :journal_text_frequencies
end
