namespace :keyword_stats do 
  desc("Computes the score field in the mesh_keywords table")
  task(:compute_mesh_scores => :environment) do
    mesh_keywords = MeshKeyword.find(:all)
    max_frequency = 0
    
    mesh_keywords.each do |kw|
      if frequency = JournalMeshFrequency.sum(:frequency, :conditions => ['mesh_id = ?', kw.id])
        max_frequency = frequency if frequency > max_frequency
        kw.score = frequency # Holy shit this is a hack. I have been ex-communicated from the church of bad design
      end
    end
    
    mesh_keywords.each do |kw|
      if kw.score
        kw.score = kw.score / max_frequency
      else
        kw.score = 0.0
      end
      kw.save
    end
  end
  
  desc("Computes the score field in the text_keywords table")
  task(:compute_text_scores => :environment) do
    text_keywords = TextKeyword.find(:all)
    max_frequency = 0
    stop_words = %w(indroduction background methods results discussion conclusion conclusions motivation abstract)
    
    text_keywords.each do |kw|
      if frequency = JournalTextFrequency.sum(:frequency, :conditions => ['text_keyword_id = ?', kw.id])
        max_frequency = frequency if frequency > max_frequency
        kw.score = frequency # Holy shit this is a hack. I have been ex-communicated from the church of bad design
      end
    end
    
    text_keywords.each do |kw|
      if stop_words.include?(kw.name)
        kw.score = 1.0
      else
        if kw.score
          kw.score = kw.score / max_frequency
        else
          kw.score = 0.0
        end
      end
      kw.save
    end
  end
end