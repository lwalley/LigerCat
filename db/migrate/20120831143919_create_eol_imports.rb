class CreateEolImports < ActiveRecord::Migration
  def change
    create_table :eol_imports do |t|
      t.string :checksum

      t.timestamps
    end
    
    add_index :eol_imports, :checksum    
    
  end
end
