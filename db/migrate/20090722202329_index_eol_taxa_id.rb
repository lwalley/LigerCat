class IndexEolTaxaId < ActiveRecord::Migration
  def self.up
    add_index :pubmed_queries, :eol_taxa_id
  end

  def self.down
    remove_index :pubmed_queries, :eol_taxa_id
  end
end
