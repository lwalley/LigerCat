class SubjectTerm < ActiveRecord::Base
  self.table_name = "journal_keywords"
  has_many :journals, :through => :journal_classifications
end
