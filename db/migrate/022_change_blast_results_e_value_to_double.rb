class ChangeBlastResultsEValueToDouble < ActiveRecord::Migration
  def self.up
    change_column :blast_results, :e_value, :double
  end

  def self.down
    change_column :blast_results, :e_value, :float
  end
end
