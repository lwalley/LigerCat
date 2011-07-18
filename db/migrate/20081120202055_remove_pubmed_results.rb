class RemovePubmedResults < ActiveRecord::Migration
  def self.up
    drop_table :pubmed_results
  end

  def self.down
    create_table "pubmed_results", :force => true do |t|
      t.integer  "pubmed_query_id"
      t.integer  "pmid"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
