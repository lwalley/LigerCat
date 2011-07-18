class JournalResult < ActiveRecord::Base
  belongs_to :journal
  belongs_to :journal_query
end
