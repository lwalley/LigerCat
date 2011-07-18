class AddNumArticlesToPubmedQueries < ActiveRecord::Migration
  def self.up
    add_column :pubmed_queries, :num_articles, :integer
  end

  def self.down
    remove_column :pubmed_queries, :num_articles
  end
end
