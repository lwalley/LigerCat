# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120831143919) do

  create_table "eol_imports", :force => true do |t|
    t.string   "checksum"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "eol_taxon_concepts", :force => true do |t|
    t.integer  "query_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "eol_taxon_concepts", ["query_id"], :name => "index_eol_taxon_concepts_on_query_id"

  create_table "gi_numbers_pmids", :force => true do |t|
    t.integer "gi_number"
    t.integer "pmid"
  end

  add_index "gi_numbers_pmids", ["gi_number"], :name => "index_gi_numbers_pmids_on_gi_number"
  add_index "gi_numbers_pmids", ["pmid"], :name => "index_gi_numbers_pmids_on_pmid"

  create_table "mesh_frequencies", :force => true do |t|
    t.integer  "query_id"
    t.integer  "mesh_keyword_id"
    t.integer  "frequency"
    t.integer  "weighted_frequency"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "mesh_frequencies", ["mesh_keyword_id"], :name => "index_mesh_frequencies_on_mesh_keyword_id"
  add_index "mesh_frequencies", ["query_id"], :name => "index_mesh_frequencies_on_query_id"

  create_table "mesh_keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "publication_dates", :force => true do |t|
    t.integer  "query_id"
    t.integer  "year"
    t.integer  "publication_count"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "publication_dates", ["query_id"], :name => "index_publication_dates_on_query_id"

  create_table "queries", :force => true do |t|
    t.string   "type"
    t.integer  "state"
    t.string   "key"
    t.text     "query"
    t.integer  "num_articles"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "queries", ["key"], :name => "index_queries_on_key"
  add_index "queries", ["type"], :name => "index_queries_on_type"
  add_index "queries", ["updated_at"], :name => "index_queries_on_updated_at"

  create_table "sequences", :force => true do |t|
    t.integer  "query_id"
    t.text     "fasta_data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sequences", ["query_id"], :name => "index_sequences_on_query_id"

end
