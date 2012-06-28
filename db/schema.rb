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

ActiveRecord::Schema.define(:version => 20120628142918) do

  create_table "blast_mesh_frequencies", :force => true do |t|
    t.integer  "blast_query_id"
    t.integer  "mesh_keyword_id"
    t.integer  "frequency"
    t.integer  "weighted_frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blast_mesh_frequencies", ["blast_query_id"], :name => "index_blast_mesh_frequencies_on_blast_query_id"
  add_index "blast_mesh_frequencies", ["mesh_keyword_id"], :name => "index_blast_mesh_frequencies_on_mesh_keyword_id"

  create_table "blast_queries", :force => true do |t|
    t.integer  "state"
    t.string   "query_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blast_queries", ["query_key"], :name => "index_blast_queries_on_query_key"
  add_index "blast_queries", ["state"], :name => "index_blast_queries_on_state"
  add_index "blast_queries", ["updated_at"], :name => "index_blast_queries_on_updated_at"

  create_table "gi_numbers_pmids", :force => true do |t|
    t.integer "gi_number"
    t.integer "pmid"
  end

  add_index "gi_numbers_pmids", ["gi_number"], :name => "index_gi_numbers_pmids_on_gi_number"
  add_index "gi_numbers_pmids", ["pmid"], :name => "index_gi_numbers_pmids_on_pmid"

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
    t.text     "query"
    t.string   "query_key"
    t.integer  "state"
    t.integer  "max_mesh_score"
    t.integer  "max_text_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_queries", ["query_key"], :name => "index_journal_queries_on_query_key"
  add_index "journal_queries", ["state"], :name => "index_journal_queries_on_state"

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
    t.boolean  "new_journal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mesh_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publication_dates", :force => true do |t|
    t.integer  "query_id"
    t.string   "query_type"
    t.integer  "year"
    t.integer  "publication_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publication_dates", ["query_type", "query_id"], :name => "index_publication_dates_on_query_type_and_query_id"

  create_table "pubmed_mesh_frequencies", :force => true do |t|
    t.integer  "pubmed_query_id"
    t.integer  "mesh_keyword_id"
    t.integer  "frequency"
    t.integer  "weighted_frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pubmed_mesh_frequencies", ["mesh_keyword_id"], :name => "index_pubmed_mesh_frequencies_on_mesh_keyword_id"
  add_index "pubmed_mesh_frequencies", ["pubmed_query_id"], :name => "index_pubmed_mesh_frequencies_on_pubmed_query_id"

  create_table "pubmed_queries", :force => true do |t|
    t.text     "query"
    t.string   "query_key"
    t.integer  "state"
    t.integer  "num_articles"
    t.string   "full_species_name"
    t.integer  "eol_taxa_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pubmed_queries", ["eol_taxa_id"], :name => "index_pubmed_queries_on_eol_taxa_id"
  add_index "pubmed_queries", ["query_key"], :name => "index_pubmed_queries_on_query_key"
  add_index "pubmed_queries", ["state"], :name => "index_pubmed_queries_on_state"
  add_index "pubmed_queries", ["updated_at"], :name => "index_pubmed_queries_on_updated_at"

  create_table "sequences", :force => true do |t|
    t.integer  "blast_query_id"
    t.text     "fasta_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["blast_query_id"], :name => "index_sequences_on_blast_query_id"

  create_table "text_keywords", :force => true do |t|
    t.string   "name"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
