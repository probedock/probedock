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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141031124422) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_settings", force: true do |t|
    t.string   "ticketing_system_url"
    t.datetime "updated_at",             null: false
    t.integer  "reports_cache_size",     null: false
    t.integer  "tag_cloud_size",         null: false
    t.integer  "test_outdated_days",     null: false
    t.integer  "test_payloads_lifespan", null: false
    t.integer  "test_runs_lifespan",     null: false
  end

  create_table "categories", force: true do |t|
    t.string   "name",                 null: false
    t.datetime "created_at",           null: false
    t.string   "metric_key", limit: 5, null: false
  end

  add_index "categories", ["metric_key"], name: "index_categories_on_metric_key", unique: true, using: :btree
  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "link_templates", force: true do |t|
    t.string   "name",       limit: 50, null: false
    t.string   "contents",              null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "link_templates", ["name"], name: "index_link_templates_on_name", unique: true, using: :btree

  create_table "links", force: true do |t|
    t.string   "name",       limit: 50, null: false
    t.string   "url",                   null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "project_versions", force: true do |t|
    t.string   "name",       null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", null: false
  end

  add_index "project_versions", ["project_id", "name"], name: "index_project_versions_on_project_id_and_name", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                   limit: 100,             null: false
    t.string   "key",                    limit: 12,              null: false
    t.integer  "tests_count",                        default: 0, null: false
    t.integer  "deprecated_tests_count",             default: 0, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "description"
  end

  add_index "projects", ["key"], name: "index_projects_on_key", unique: true, using: :btree

  create_table "purge_actions", force: true do |t|
    t.string   "data_type",     limit: 20,             null: false
    t.integer  "number_purged",            default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "tags", force: true do |t|
    t.string "name", limit: 50, null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tags_test_infos", id: false, force: true do |t|
    t.integer "tag_id",       null: false
    t.integer "test_info_id", null: false
  end

  add_index "tags_test_infos", ["tag_id", "test_info_id"], name: "index_tags_test_infos_on_tag_id_and_test_info_id", unique: true, using: :btree
  add_index "tags_test_infos", ["test_info_id"], name: "tags_test_infos_test_info_id_fk", using: :btree

  create_table "test_counters", force: true do |t|
    t.string   "timezone",           limit: 30,              null: false
    t.datetime "timestamp",                                  null: false
    t.integer  "mask",                                       null: false
    t.string   "unique_token",       limit: 100,             null: false
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "project_id"
    t.integer  "written_counter",                default: 0, null: false
    t.integer  "run_counter",                    default: 0, null: false
    t.integer  "total_written"
    t.integer  "total_run"
    t.integer  "deprecated_counter",             default: 0, null: false
    t.integer  "total_deprecated"
  end

  add_index "test_counters", ["category_id"], name: "test_counters_category_id_fk", using: :btree
  add_index "test_counters", ["project_id"], name: "test_counters_project_id_fk", using: :btree
  add_index "test_counters", ["timezone", "timestamp", "mask"], name: "index_test_counters_on_timezone_and_timestamp_and_mask", using: :btree
  add_index "test_counters", ["unique_token"], name: "index_test_counters_on_unique_token", unique: true, using: :btree
  add_index "test_counters", ["user_id"], name: "test_counters_user_id_fk", using: :btree

  create_table "test_deprecations", force: true do |t|
    t.boolean  "deprecated",   null: false
    t.integer  "test_info_id", null: false
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.integer  "category_id"
  end

  add_index "test_deprecations", ["test_info_id"], name: "test_deprecations_test_info_id_fk", using: :btree
  add_index "test_deprecations", ["user_id"], name: "test_deprecations_user_id_fk", using: :btree

  create_table "test_infos", force: true do |t|
    t.string   "name",                               null: false
    t.integer  "author_id",                          null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "key_id",                             null: false
    t.boolean  "passing",                            null: false
    t.integer  "effective_result_id"
    t.datetime "last_run_at",                        null: false
    t.boolean  "active",              default: true, null: false
    t.integer  "last_run_duration",                  null: false
    t.integer  "project_id",                         null: false
    t.integer  "category_id"
    t.integer  "deprecation_id"
    t.integer  "results_count",       default: 0,    null: false
    t.integer  "last_runner_id"
  end

  add_index "test_infos", ["author_id"], name: "test_infos_author_id_fk", using: :btree
  add_index "test_infos", ["category_id"], name: "test_infos_category_id_fk", using: :btree
  add_index "test_infos", ["deprecation_id"], name: "test_infos_deprecation_id_fk", using: :btree
  add_index "test_infos", ["effective_result_id"], name: "test_infos_effective_result_id_fk", using: :btree
  add_index "test_infos", ["key_id", "project_id"], name: "index_test_infos_on_key_id_and_project_id", unique: true, using: :btree
  add_index "test_infos", ["last_runner_id"], name: "test_infos_last_runner_id_fk", using: :btree
  add_index "test_infos", ["project_id"], name: "test_infos_project_id_fk", using: :btree

  create_table "test_infos_tickets", id: false, force: true do |t|
    t.integer "test_info_id", null: false
    t.integer "ticket_id",    null: false
  end

  add_index "test_infos_tickets", ["test_info_id", "ticket_id"], name: "index_test_infos_tickets_on_test_info_id_and_ticket_id", unique: true, using: :btree
  add_index "test_infos_tickets", ["ticket_id"], name: "test_infos_tickets_ticket_id_fk", using: :btree

  create_table "test_keys", force: true do |t|
    t.string   "key",        limit: 12,                null: false
    t.integer  "user_id",                              null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "free",                  default: true, null: false
    t.integer  "project_id",                           null: false
  end

  add_index "test_keys", ["key", "project_id"], name: "index_test_keys_on_key_and_project_id", unique: true, using: :btree
  add_index "test_keys", ["project_id"], name: "test_keys_project_id_fk", using: :btree
  add_index "test_keys", ["user_id"], name: "test_keys_user_id_fk", using: :btree

  create_table "test_keys_payloads", id: false, force: true do |t|
    t.integer "test_key_id",     null: false
    t.integer "test_payload_id", null: false
  end

  add_index "test_keys_payloads", ["test_key_id", "test_payload_id"], name: "index_test_keys_payloads_on_test_key_id_and_test_payload_id", unique: true, using: :btree
  add_index "test_keys_payloads", ["test_payload_id"], name: "test_keys_payloads_test_payload_id_fk", using: :btree

  create_table "test_payloads", force: true do |t|
    t.text     "contents",                     null: false
    t.integer  "contents_bytesize",            null: false
    t.string   "state",             limit: 12, null: false
    t.datetime "received_at",                  null: false
    t.datetime "processing_at"
    t.datetime "processed_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id",                      null: false
    t.integer  "test_run_id"
  end

  add_index "test_payloads", ["state"], name: "index_test_payloads_on_state", using: :btree
  add_index "test_payloads", ["test_run_id"], name: "test_payloads_test_run_id_fk", using: :btree
  add_index "test_payloads", ["user_id"], name: "test_payloads_user_id_fk", using: :btree

  create_table "test_results", force: true do |t|
    t.boolean  "passed",                               null: false
    t.integer  "runner_id",                            null: false
    t.integer  "test_info_id",                         null: false
    t.datetime "created_at",                           null: false
    t.datetime "run_at",                               null: false
    t.integer  "duration",                             null: false
    t.text     "message"
    t.integer  "test_run_id",                          null: false
    t.boolean  "active",               default: true,  null: false
    t.integer  "project_version_id",                   null: false
    t.boolean  "new_test",             default: false, null: false
    t.integer  "category_id"
    t.integer  "previous_category_id"
    t.boolean  "previous_passed"
    t.boolean  "previous_active"
    t.boolean  "deprecated",           default: false, null: false
  end

  add_index "test_results", ["category_id"], name: "test_results_category_id_fk", using: :btree
  add_index "test_results", ["previous_category_id"], name: "test_results_previous_category_id_fk", using: :btree
  add_index "test_results", ["project_version_id"], name: "test_results_project_version_id_fk", using: :btree
  add_index "test_results", ["runner_id"], name: "test_results_runner_id_fk", using: :btree
  add_index "test_results", ["test_info_id"], name: "test_results_test_info_id_fk", using: :btree
  add_index "test_results", ["test_run_id", "test_info_id"], name: "index_test_results_on_test_run_id_and_test_info_id", unique: true, using: :btree

  create_table "test_runs", force: true do |t|
    t.string   "uid"
    t.string   "group"
    t.datetime "ended_at",                      null: false
    t.integer  "duration",                      null: false
    t.integer  "runner_id",                     null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "results_count",                 null: false
    t.integer  "passed_results_count",          null: false
    t.integer  "inactive_results_count",        null: false
    t.integer  "inactive_passed_results_count", null: false
  end

  add_index "test_runs", ["group"], name: "index_test_runs_on_group", using: :btree
  add_index "test_runs", ["runner_id"], name: "test_runs_runner_id_fk", using: :btree
  add_index "test_runs", ["uid"], name: "index_test_runs_on_uid", unique: true, using: :btree

  create_table "test_values", force: true do |t|
    t.string  "name",         limit: 50, null: false
    t.text    "contents",                null: false
    t.integer "test_info_id",            null: false
  end

  add_index "test_values", ["test_info_id", "name"], name: "index_test_values_on_test_info_id_and_name", unique: true, using: :btree

  create_table "tickets", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tickets", ["name"], name: "index_tickets_on_name", unique: true, using: :btree

  create_table "user_settings", force: true do |t|
    t.integer  "last_test_key_project_id"
    t.datetime "updated_at",               null: false
    t.integer  "last_test_key_number"
  end

  add_index "user_settings", ["last_test_key_project_id"], name: "user_settings_last_test_key_project_id_fk", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                           null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "sign_in_count",   default: 0
    t.integer  "roles_mask",      default: 0,    null: false
    t.string   "email"
    t.integer  "last_run_id"
    t.boolean  "active",          default: true, null: false
    t.integer  "settings_id",                    null: false
    t.string   "password_digest",                null: false
  end

  add_index "users", ["last_run_id"], name: "users_last_run_id_fk", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["settings_id"], name: "index_users_on_settings_id", unique: true, using: :btree

  add_foreign_key "project_versions", "projects", name: "project_versions_project_id_fk"

  add_foreign_key "tags_test_infos", "tags", name: "tags_test_infos_tag_id_fk"
  add_foreign_key "tags_test_infos", "test_infos", name: "tags_test_infos_test_info_id_fk"

  add_foreign_key "test_counters", "categories", name: "test_counters_category_id_fk"
  add_foreign_key "test_counters", "projects", name: "test_counters_project_id_fk"
  add_foreign_key "test_counters", "users", name: "test_counters_user_id_fk"

  add_foreign_key "test_deprecations", "test_infos", name: "test_deprecations_test_info_id_fk"
  add_foreign_key "test_deprecations", "users", name: "test_deprecations_user_id_fk"

  add_foreign_key "test_infos", "categories", name: "test_infos_category_id_fk"
  add_foreign_key "test_infos", "projects", name: "test_infos_project_id_fk"
  add_foreign_key "test_infos", "test_deprecations", name: "test_infos_deprecation_id_fk", column: "deprecation_id"
  add_foreign_key "test_infos", "test_results", name: "test_infos_effective_result_id_fk", column: "effective_result_id", dependent: :nullify
  add_foreign_key "test_infos", "users", name: "test_infos_author_id_fk", column: "author_id"
  add_foreign_key "test_infos", "users", name: "test_infos_last_runner_id_fk", column: "last_runner_id"

  add_foreign_key "test_infos_tickets", "test_infos", name: "test_infos_tickets_test_info_id_fk"
  add_foreign_key "test_infos_tickets", "tickets", name: "test_infos_tickets_ticket_id_fk"

  add_foreign_key "test_keys", "projects", name: "test_keys_project_id_fk"
  add_foreign_key "test_keys", "users", name: "test_keys_user_id_fk"

  add_foreign_key "test_keys_payloads", "test_keys", name: "test_keys_payloads_test_key_id_fk"
  add_foreign_key "test_keys_payloads", "test_payloads", name: "test_keys_payloads_test_payload_id_fk", dependent: :delete

  add_foreign_key "test_payloads", "test_runs", name: "test_payloads_test_run_id_fk", dependent: :delete
  add_foreign_key "test_payloads", "users", name: "test_payloads_user_id_fk"

  add_foreign_key "test_results", "categories", name: "test_results_category_id_fk"
  add_foreign_key "test_results", "categories", name: "test_results_previous_category_id_fk", column: "previous_category_id"
  add_foreign_key "test_results", "project_versions", name: "test_results_project_version_id_fk"
  add_foreign_key "test_results", "test_infos", name: "test_results_test_info_id_fk"
  add_foreign_key "test_results", "test_runs", name: "test_results_test_run_id_fk", dependent: :delete
  add_foreign_key "test_results", "users", name: "test_results_runner_id_fk", column: "runner_id"

  add_foreign_key "test_runs", "users", name: "test_runs_runner_id_fk", column: "runner_id"

  add_foreign_key "test_values", "test_infos", name: "test_values_test_info_id_fk"

  add_foreign_key "user_settings", "projects", name: "user_settings_last_test_key_project_id_fk", column: "last_test_key_project_id"

  add_foreign_key "users", "test_runs", name: "users_last_run_id_fk", column: "last_run_id", dependent: :nullify
  add_foreign_key "users", "user_settings", name: "users_settings_id_fk", column: "settings_id"

end
