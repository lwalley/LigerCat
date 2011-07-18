namespace :purge do
  desc "Purges all BlastQueries (and friends) from the database"
  task :blast_queries => :environment do
    BlastQuery.transaction do 
      BlastQuery.delete_all
      BlastMeshFrequency.delete_all
      Sequence.delete_all
      clear_caches('genes')
    end
  end
  
  desc "Purges all PubmedQueries (and friends) from the database"
  task :pubmed_queries => :environment do
    PubmedQuery.transaction do 
      PubmedQuery.delete_all
      PublicationDate.delete_all("query_type = 'PubmedQuery'")
      PubmedMeshFrequency.delete_all
      clear_caches('articles')
    end
  end
  
  desc "Purges all JournalQueries (and friends) from the database"
  task :journal_queries => :environment do
    JournalQuery.transaction do 
      JournalQuery.delete_all
      JournalResult.delete_all
      clear_caches('journals')
    end
  end
  
  def clear_caches(dir)
    FileUtils.rm_rf("#{RAILS_ROOT}/public/#{dir}")
    Rake::Task[ "tmp:cache:clear" ].execute
  end
end
