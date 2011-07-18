class AddStatisticalFieldsToResultsTable < ActiveRecord::Migration
  def self.up
    remove_column :results, :rank
    add_column :results, :search_term_score, :float
    add_column :results, :mesh_score, :int
    add_column :results, :text_score, :int
  end

  def self.down
    add_column :results, :rank, :float
    remove_column :results, :search_term_rank
    remove_column :results, :mesh_score
    remove_column :results, :text_score
  end
end
