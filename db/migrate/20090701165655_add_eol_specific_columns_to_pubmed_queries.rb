class AddEolSpecificColumnsToPubmedQueries < ActiveRecord::Migration
  def self.up
    add_column :pubmed_queries, :full_species_name, :string, :defaut => nil
		add_column :pubmed_queries, :eol_taxa_id, :integer, :default => nil
  end

  def self.down
    remove_column :pubmed_queries, :full_species_name
		remove_column :pubmed_queries, :eol_taxa_id
  end
end
