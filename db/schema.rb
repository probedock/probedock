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

ActiveRecord::Schema.define(:version => 20131211130324) do

  create_table "api_keys", :force => true do |t|
    t.string   "identifier",    :limit => 20,                   :null => false
    t.string   "shared_secret", :limit => 50,                   :null => false
    t.boolean  "active",                      :default => true, :null => false
    t.integer  "user_id",                                       :null => false
    t.integer  "usage_count",                 :default => 0,    :null => false
    t.datetime "last_used_at"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "api_keys", ["identifier"], :name => "index_api_keys_on_identifier", :unique => true
  add_index "api_keys", ["user_id"], :name => "api_keys_user_id_fk"

  create_table "app_settings", :force => true do |t|
    t.string   "ticketing_system_url"
    t.datetime "updated_at",           :null => false
    t.integer  "reports_cache_size",   :null => false
    t.integer  "tag_cloud_size",       :null => false
    t.integer  "test_outdated_days",   :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name",                    :null => false
    t.datetime "created_at",              :null => false
    t.string   "metric_key", :limit => 5, :null => false
  end

  add_index "categories", ["metric_key"], :name => "index_categories_on_metric_key", :unique => true
  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "links", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.string   "url",                      :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "project_versions", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "project_id", :null => false
    t.datetime "created_at", :null => false
  end

  add_index "project_versions", ["project_id", "name"], :name => "index_project_versions_on_project_id_and_name", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "name",                                                :null => false
    t.string   "url_token",              :limit => 25,                :null => false
    t.string   "api_id",                 :limit => 12,                :null => false
    t.integer  "active_tests_count",                   :default => 0, :null => false
    t.integer  "deprecated_tests_count",               :default => 0, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "metric_key",             :limit => 5,                 :null => false
  end

  add_index "projects", ["api_id"], :name => "index_projects_on_api_id", :unique => true
  add_index "projects", ["metric_key"], :name => "index_projects_on_metric_key", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :limit => 50, :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "tags_test_infos", :id => false, :force => true do |t|
    t.integer "tag_id",       :null => false
    t.integer "test_info_id", :null => false
  end

  add_index "tags_test_infos", ["tag_id", "test_info_id"], :name => "index_tags_test_infos_on_tag_id_and_test_info_id", :unique => true
  add_index "tags_test_infos", ["test_info_id"], :name => "tags_test_infos_test_info_id_fk"

  create_table "test_counters", :force => true do |t|
    t.string   "timezone",        :limit => 30,                 :null => false
    t.datetime "timestamp",                                     :null => false
    t.integer  "mask",                                          :null => false
    t.string   "unique_token",    :limit => 100,                :null => false
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "project_id"
    t.integer  "written_counter",                :default => 0, :null => false
    t.integer  "run_counter",                    :default => 0, :null => false
    t.integer  "total_written"
    t.integer  "total_run"
  end

  add_index "test_counters", ["category_id"], :name => "test_counters_category_id_fk"
  add_index "test_counters", ["project_id"], :name => "test_counters_project_id_fk"
  add_index "test_counters", ["timezone", "timestamp", "mask"], :name => "index_test_counters_on_timezone_and_timestamp_and_mask"
  add_index "test_counters", ["unique_token"], :name => "index_test_counters_on_unique_token", :unique => true
  add_index "test_counters", ["user_id"], :name => "test_counters_user_id_fk"

  create_table "test_infos", :force => true do |t|
    t.string   "name",                                  :null => false
    t.integer  "author_id",                             :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "key_id",                                :null => false
    t.boolean  "passing",                               :null => false
    t.integer  "effective_result_id"
    t.datetime "last_run_at",                           :null => false
    t.boolean  "active",              :default => true, :null => false
    t.integer  "last_run_duration",                     :null => false
    t.integer  "project_id",                            :null => false
    t.integer  "category_id"
    t.datetime "deprecated_at"
  end

  add_index "test_infos", ["author_id"], :name => "test_infos_author_id_fk"
  add_index "test_infos", ["category_id"], :name => "test_infos_category_id_fk"
  add_index "test_infos", ["effective_result_id"], :name => "test_infos_effective_result_id_fk"
  add_index "test_infos", ["key_id", "project_id"], :name => "index_test_infos_on_key_id_and_project_id", :unique => true
  add_index "test_infos", ["project_id"], :name => "test_infos_project_id_fk"

  create_table "test_infos_tickets", :id => false, :force => true do |t|
    t.integer "test_info_id", :null => false
    t.integer "ticket_id",    :null => false
  end

  add_index "test_infos_tickets", ["test_info_id", "ticket_id"], :name => "index_test_infos_tickets_on_test_info_id_and_ticket_id", :unique => true
  add_index "test_infos_tickets", ["ticket_id"], :name => "test_infos_tickets_ticket_id_fk"

  create_table "test_keys", :force => true do |t|
    t.string   "key",        :limit => 12,                   :null => false
    t.integer  "user_id",                                    :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "free",                     :default => true, :null => false
    t.integer  "project_id",                                 :null => false
  end

  add_index "test_keys", ["key", "project_id"], :name => "index_test_keys_on_key_and_project_id", :unique => true
  add_index "test_keys", ["project_id"], :name => "test_keys_project_id_fk"
  add_index "test_keys", ["user_id"], :name => "test_keys_user_id_fk"

  create_table "test_results", :force => true do |t|
    t.boolean  "passed",                                  :null => false
    t.integer  "runner_id",                               :null => false
    t.integer  "test_info_id",                            :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "run_at",                                  :null => false
    t.integer  "duration",                                :null => false
    t.text     "message"
    t.integer  "test_run_id",                             :null => false
    t.boolean  "active",               :default => true,  :null => false
    t.integer  "project_version_id",                      :null => false
    t.boolean  "new_test",             :default => false, :null => false
    t.integer  "category_id"
    t.integer  "previous_category_id"
    t.boolean  "previous_passed"
    t.boolean  "previous_active"
    t.boolean  "deprecated",           :default => false, :null => false
  end

  add_index "test_results", ["category_id"], :name => "test_results_category_id_fk"
  add_index "test_results", ["previous_category_id"], :name => "test_results_previous_category_id_fk"
  add_index "test_results", ["project_version_id"], :name => "test_results_project_version_id_fk"
  add_index "test_results", ["runner_id"], :name => "test_results_runner_id_fk"
  add_index "test_results", ["test_info_id"], :name => "test_results_test_info_id_fk"
  add_index "test_results", ["test_run_id", "test_info_id"], :name => "index_test_results_on_test_run_id_and_test_info_id", :unique => true

  create_table "test_runs", :force => true do |t|
    t.string   "uid"
    t.string   "group"
    t.datetime "ended_at",                      :null => false
    t.integer  "duration",                      :null => false
    t.integer  "runner_id",                     :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "results_count",                 :null => false
    t.integer  "passed_results_count",          :null => false
    t.integer  "inactive_results_count",        :null => false
    t.integer  "inactive_passed_results_count", :null => false
  end

  add_index "test_runs", ["group"], :name => "index_test_runs_on_group"
  add_index "test_runs", ["runner_id"], :name => "test_runs_runner_id_fk"
  add_index "test_runs", ["uid"], :name => "index_test_runs_on_uid", :unique => true

  create_table "test_values", :force => true do |t|
    t.string  "name",         :limit => 50, :null => false
    t.string  "contents",                   :null => false
    t.integer "test_info_id",               :null => false
  end

  add_index "test_values", ["test_info_id", "name"], :name => "index_test_values_on_test_info_id_and_name", :unique => true

  create_table "tickets", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tickets", ["name"], :name => "index_tickets_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",                                                :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "roles_mask",                        :default => 0,    :null => false
    t.string   "email"
    t.string   "remember_token",      :limit => 16
    t.integer  "last_run_id"
    t.string   "encrypted_password"
    t.string   "metric_key",          :limit => 5,                    :null => false
    t.boolean  "active",                            :default => true, :null => false
  end

  add_index "users", ["last_run_id"], :name => "users_last_run_id_fk"
  add_index "users", ["metric_key"], :name => "index_users_on_metric_key", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

  add_foreign_key "api_keys", "users", :name => "api_keys_user_id_fk"

  add_foreign_key "project_versions", "projects", :name => "project_versions_project_id_fk"

  add_foreign_key "tags_test_infos", "tags", :name => "tags_test_infos_tag_id_fk"
  add_foreign_key "tags_test_infos", "test_infos", :name => "tags_test_infos_test_info_id_fk"

  add_foreign_key "test_counters", "categories", :name => "test_counters_category_id_fk"
  add_foreign_key "test_counters", "projects", :name => "test_counters_project_id_fk"
  add_foreign_key "test_counters", "users", :name => "test_counters_user_id_fk"

  add_foreign_key "test_infos", "categories", :name => "test_infos_category_id_fk"
  add_foreign_key "test_infos", "projects", :name => "test_infos_project_id_fk"
  add_foreign_key "test_infos", "test_results", :name => "test_infos_effective_result_id_fk", :column => "effective_result_id"
  add_foreign_key "test_infos", "users", :name => "test_infos_author_id_fk", :column => "author_id"

  add_foreign_key "test_infos_tickets", "test_infos", :name => "test_infos_tickets_test_info_id_fk"
  add_foreign_key "test_infos_tickets", "tickets", :name => "test_infos_tickets_ticket_id_fk"

  add_foreign_key "test_keys", "projects", :name => "test_keys_project_id_fk"
  add_foreign_key "test_keys", "users", :name => "test_keys_user_id_fk"

  add_foreign_key "test_results", "categories", :name => "test_results_category_id_fk"
  add_foreign_key "test_results", "categories", :name => "test_results_previous_category_id_fk", :column => "previous_category_id"
  add_foreign_key "test_results", "project_versions", :name => "test_results_project_version_id_fk"
  add_foreign_key "test_results", "test_infos", :name => "test_results_test_info_id_fk"
  add_foreign_key "test_results", "test_runs", :name => "test_results_test_run_id_fk"
  add_foreign_key "test_results", "users", :name => "test_results_runner_id_fk", :column => "runner_id"

  add_foreign_key "test_runs", "users", :name => "test_runs_runner_id_fk", :column => "runner_id"

  add_foreign_key "test_values", "test_infos", :name => "test_values_test_info_id_fk"

  add_foreign_key "users", "test_runs", :name => "users_last_run_id_fk", :column => "last_run_id"

end
