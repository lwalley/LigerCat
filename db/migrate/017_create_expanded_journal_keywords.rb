class CreateExpandedJournalKeywords < ActiveRecord::Migration
  def self.up
    create_table :expanded_journal_keywords do |t|
      t.string :name
    end
    
    subject_terms = Hash.new # We're using a hash to ensure uniqueness
    File.open(RAILS_ROOT + "/lib/journalSubjectTerms.txt").each do |journal_subject_line|
      name = journal_subject_line.split('|').first
      name.tr!('+', ' ')
      subject_terms[name] ||= { :name => name }
    end
    
    ExpandedJournalKeyword.create(subject_terms.values)
  end

  def self.down
    drop_table :expanded_journal_keywords
  end
end
