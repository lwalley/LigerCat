class ReplaceEValueWithWeightedFrequency < ActiveRecord::Migration
  def self.up
    [:blast_mesh_frequencies, :pubmed_mesh_frequencies].each do |table_name|
      
      change_table table_name do |t|
        t.remove :e_value
        t.integer :weighted_frequency
      end
      
    end
  end

  def self.down
    [:blast_mesh_frequencies, :pubmed_mesh_frequencies].each do |table_name|
      
      change_table table_name do |t|
        t.float :e_value
        t.remove :weighted_frequency
      end
      
    end
    
  end
end
