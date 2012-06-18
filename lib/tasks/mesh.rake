namespace :mesh do
  desc "Removes all MeSH terms from the mesh_keywords table"
  task :purge => :environment do
    puts "Purging database of all existing MeSH Terms"
    MeshKeyword.delete_all
  end
  
  desc "Loads MeSH terms from the MeshKeywordLookup module"
  task :load => [:environment, :purge] do
    require 'progressbar'
    puts "Loading MeSH terms from mesh_keyword_lookup"
    pbar = ProgressBar.new("loading", MeshKeywordLookup.length)
    MeshKeywordLookup.each do |name, id|
      pbar.inc
      sql = MeshKeyword.send(:sanitize_sql, ["INSERT INTO `#{MeshKeyword.table_name}` (`created_at`, `updated_at`, `id`, `name`) VALUES(NOW(), NOW(), #{id}, '%s')", name.titleize])      
      MeshKeyword.connection.execute(sql)
    end
    pbar.finish
  end
end
