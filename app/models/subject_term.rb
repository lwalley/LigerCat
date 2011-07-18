class SubjectTerm < ActiveRecord::Base
  set_table_name "journal_keywords"
  has_many :journals, :through => :journal_classifications
end
