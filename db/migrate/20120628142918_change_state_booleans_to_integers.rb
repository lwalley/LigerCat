class ChangeStateBooleansToIntegers < ActiveRecord::Migration
  def self.up
    
    [:blast_queries, :pubmed_queries].each do |table_name|
      change_column table_name, :state, :integer
      add_index     table_name, :state
    end
  end

  def self.down
    [:blast_queries, :pubmed_queries].each do |table_name|
      change_column table_name, :state, :boolean
      remove_index  table_name, :state
    end
    
  end
end
