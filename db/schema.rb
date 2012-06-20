# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120620170635) do

  create_table "blast_mesh_frequencies", :force => true do |t|
    t.integer  "blast_query_id"
    t.integer  "mesh_keyword_id"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weighted_frequency"
  end

  add_index "blast_mesh_frequencies", ["blast_query_id", "mesh_keyword_id"], :name => "by_blast_query_id_and_mesh_keyword_id"
  add_index "blast_mesh_frequencies", ["blast_query_id"], :name => "index_blast_mesh_frequencies_on_blast_query_id"
  add_index "blast_mesh_frequencies", ["mesh_keyword_id"], :name => "index_blast_mesh_frequencies_on_mesh_keyword_id"

  create_table "blast_queries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state"
    t.string   "query_key",  :limit => 40
  end

  add_index "blast_queries", ["query_key"], :name => "index_blast_queries_on_query_key"
  add_index "blast_queries", ["state"], :name => "index_blast_queries_on_state"
  add_index "blast_queries", ["updated_at"], :name => "index_blast_queries_on_updated_at"

  create_table "blast_results", :force => true do |t|
    t.integer  "sequence_id"
    t.integer  "blast_query_id"
    t.float    "e_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blast_results", ["blast_query_id"], :name => "index_blast_results_on_blast_query_id"
  add_index "blast_results", ["sequence_id"], :name => "index_blast_results_on_sequence_id"

  create_table "expanded_journal_keywords", :force => true do |t|
    t.string "name"
  end

  create_table "gi_numbers_pmids", :id => false, :force => true do |t|
    t.integer "gi_number", :default => 0, :null => false
    t.integer "pmid",      :default => 0, :null => false
  end

  create_table "journal_classifications", :force => true do |t|
    t.integer  "journal_id"
    t.integer  "journal_keyword_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_classifications", ["journal_id"], :name => "index_journal_classifications_on_journal_id"
  add_index "journal_classifications", ["journal_keyword_id"], :name => "index_journal_classifications_on_journal_keyword_id"

  create_table "journal_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_mesh_frequencies", :force => true do |t|
    t.integer  "journal_id"
    t.integer  "mesh_id"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_mesh_frequencies", ["journal_id"], :name => "index_journal_mesh_frequencies_on_journal_id"
  add_index "journal_mesh_frequencies", ["mesh_id"], :name => "index_journal_mesh_frequencies_on_mesh_id"

  create_table "journal_queries", :force => true do |t|
    t.integer  "max_mesh_score"
    t.integer  "max_text_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state"
    t.text     "query"
    t.string   "query_key",      :limit => 40
  end

  add_index "journal_queries", ["query_key"], :name => "index_journal_queries_on_query_key"

  create_table "journal_results", :force => true do |t|
    t.integer  "journal_id"
    t.integer  "journal_query_id"
    t.float    "search_term_score"
    t.integer  "mesh_score"
    t.integer  "text_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_results", ["journal_id"], :name => "index_journal_results_on_journal_id"
  add_index "journal_results", ["journal_query_id"], :name => "index_journal_results_on_journal_query_id"

  create_table "journal_text_frequencies", :force => true do |t|
    t.integer  "journal_id"
    t.integer  "text_keyword_id"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_text_frequencies", ["journal_id"], :name => "index_journal_text_frequencies_on_journal_id"
  add_index "journal_text_frequencies", ["text_keyword_id"], :name => "index_journal_text_frequencies_on_text_keyword_id"

  create_table "journals", :force => true do |t|
    t.text     "title"
    t.string   "nlm_id"
    t.string   "title_abbreviation"
    t.string   "issn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "new_journal",        :default => false
  end

  create_table "mesh_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nuccore_queries", :force => true do |t|
    t.string   "query"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "done",       :default => false
  end

  add_index "nuccore_queries", ["query"], :name => "index_nuccore_queries_on_query"

  create_table "nuccore_results", :force => true do |t|
    t.integer  "sequence_id"
    t.integer  "nuccore_query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nuccore_results", ["nuccore_query_id"], :name => "index_nuccore_results_on_nuccore_query_id"
  add_index "nuccore_results", ["sequence_id"], :name => "index_nuccore_results_on_sequence_id"

  create_table "pmids_mesh_keywords", :id => false, :force => true do |t|
    t.integer "pmid"
    t.integer "mesh_keyword_id"
  end

  add_index "pmids_mesh_keywords", ["pmid", "mesh_keyword_id"], :name => "index_pmids_mesh_ids_on_pmid_and_mesh_keyword_id"

  create_table "publication_dates", :force => true do |t|
    t.integer "query_id",                        :null => false
    t.string  "query_type",        :limit => 20, :null => false
    t.integer "year"
    t.integer "publication_count"
  end

  add_index "publication_dates", ["query_type", "query_id"], :name => "index_publication_dates_on_query_type_and_query_id"

  create_table "pubmed_mesh_frequencies", :force => true do |t|
    t.integer  "pubmed_query_id"
    t.integer  "mesh_keyword_id"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weighted_frequency"
  end

  add_index "pubmed_mesh_frequencies", ["mesh_keyword_id"], :name => "index_pubmed_mesh_frequencies_on_mesh_keyword_id"
  add_index "pubmed_mesh_frequencies", ["pubmed_query_id", "mesh_keyword_id"], :name => "by_pubmed_query_id_and_mesh_keyword_id"
  add_index "pubmed_mesh_frequencies", ["pubmed_query_id"], :name => "index_pubmed_mesh_frequencies_on_pubmed_query_id"

  create_table "pubmed_queries", :force => true do |t|
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "query"
    t.string   "query_key",         :limit => 40
    t.integer  "num_articles"
    t.string   "full_species_name"
    t.integer  "eol_taxa_id"
  end

  add_index "pubmed_queries", ["eol_taxa_id"], :name => "index_pubmed_queries_on_eol_taxa_id"
  add_index "pubmed_queries", ["query_key"], :name => "index_pubmed_queries_on_query_key"
  add_index "pubmed_queries", ["state"], :name => "index_pubmed_queries_on_state"
  add_index "pubmed_queries", ["state"], :name => "pubmed_queries_state"
  add_index "pubmed_queries", ["updated_at"], :name => "index_pubmed_queries_on_updated_at"
  add_index "pubmed_queries", ["updated_at"], :name => "pubmed_queries_updated_at"

  create_table "sequences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "fasta_data"
    t.integer  "blast_query_id"
  end

  add_index "sequences", ["blast_query_id"], :name => "index_sequences_on_blast_query_id"

  create_table "text_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score"
  end

end
