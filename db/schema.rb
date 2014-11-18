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
    t.string   "name",       null: false
    t.datetime "created_at", null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "emails", force: true do |t|
    t.string "email", null: false
  end

  add_index "emails", ["email"], name: "index_emails_on_email", unique: true, using: :btree

  create_table "link_templates", force: true do |t|
    t.string   "name",       limit: 50, null: false
    t.string   "contents",              null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "link_templates", ["name"], name: "index_link_templates_on_name", unique: true, using: :btree

  create_table "project_tests", force: true do |t|
    t.string   "name",                      null: false
    t.integer  "key_id",                    null: false
    t.integer  "project_id",                null: false
    t.integer  "results_count", default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "project_tests", ["project_id", "key_id"], name: "index_project_tests_on_project_id_and_key_id", unique: true, using: :btree

  create_table "project_versions", force: true do |t|
    t.string   "name",       null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", null: false
  end

  add_index "project_versions", ["project_id", "name"], name: "index_project_versions_on_project_id_and_name", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                   limit: 100,             null: false
    t.string   "api_id",                 limit: 12,              null: false
    t.integer  "tests_count",                        default: 0, null: false
    t.integer  "deprecated_tests_count",             default: 0, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "description"
  end

  add_index "projects", ["api_id"], name: "index_projects_on_api_id", unique: true, using: :btree

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

  create_table "tags_test_descriptions", id: false, force: true do |t|
    t.integer "test_description_id", null: false
    t.integer "tag_id",              null: false
  end

  add_index "tags_test_descriptions", ["test_description_id", "tag_id"], name: "index_tags_test_descriptions_on_test_description_id_and_tag_id", unique: true, using: :btree

  create_table "tags_test_results", id: false, force: true do |t|
    t.integer "test_result_id", null: false
    t.integer "tag_id",         null: false
  end

  add_index "tags_test_results", ["test_result_id", "tag_id"], name: "index_tags_test_results_on_test_result_id_and_tag_id", unique: true, using: :btree

  create_table "test_contributors", id: false, force: true do |t|
    t.integer "test_description_id"
    t.integer "email_id"
  end

  add_index "test_contributors", ["test_description_id", "email_id"], name: "index_test_contributors_on_description_and_email", unique: true, using: :btree

  create_table "test_custom_values", force: true do |t|
    t.string "name",     limit: 50, null: false
    t.text   "contents",            null: false
  end

  add_index "test_custom_values", ["name", "contents"], name: "index_test_custom_values_on_name_and_contents", unique: true, using: :btree

  create_table "test_custom_values_descriptions", id: false, force: true do |t|
    t.integer "test_description_id",  null: false
    t.integer "test_custom_value_id", null: false
  end

  add_index "test_custom_values_descriptions", ["test_description_id", "test_custom_value_id"], name: "index_test_custom_values_descriptions_on_desc_and_value_ids", unique: true, using: :btree

  create_table "test_custom_values_results", id: false, force: true do |t|
    t.integer "test_result_id",       null: false
    t.integer "test_custom_value_id", null: false
  end

  add_index "test_custom_values_results", ["test_result_id", "test_custom_value_id"], name: "index_test_custom_values_results_on_result_and_value_id", unique: true, using: :btree

  create_table "test_descriptions", force: true do |t|
    t.string   "name",                           null: false
    t.integer  "test_id",                        null: false
    t.integer  "project_version_id",             null: false
    t.integer  "category_id"
    t.boolean  "passing",                        null: false
    t.boolean  "active",                         null: false
    t.integer  "last_duration",                  null: false
    t.datetime "last_run_at",                    null: false
    t.integer  "last_runner_id",                 null: false
    t.integer  "last_result_id"
    t.integer  "results_count",      default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "test_descriptions", ["test_id", "project_version_id"], name: "index_test_descriptions_on_test_id_and_project_version_id", unique: true, using: :btree

  create_table "test_descriptions_tickets", id: false, force: true do |t|
    t.integer "test_description_id", null: false
    t.integer "ticket_id",           null: false
  end

  add_index "test_descriptions_tickets", ["test_description_id", "ticket_id"], name: "index_test_descriptions_on_description_and_ticket", unique: true, using: :btree

  create_table "test_keys", force: true do |t|
    t.string   "key",        limit: 12,                null: false
    t.integer  "user_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "free",                  default: true, null: false
    t.integer  "project_id",                           null: false
    t.boolean  "tracked",               default: true, null: false
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
    t.integer  "contents_bytesize",                                    null: false
    t.string   "state",                         limit: 12,             null: false
    t.datetime "received_at",                                          null: false
    t.datetime "processing_at"
    t.datetime "processed_at"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "runner_id",                                            null: false
    t.string   "api_id",                        limit: 36,             null: false
    t.json     "contents",                                             null: false
    t.integer  "duration"
    t.datetime "run_ended_at"
    t.integer  "results_count",                            default: 0, null: false
    t.integer  "passed_results_count",                     default: 0, null: false
    t.integer  "inactive_results_count",                   default: 0, null: false
    t.integer  "inactive_passed_results_count",            default: 0, null: false
    t.integer  "project_version_id"
    t.text     "backtrace"
    t.integer  "processed_results_count",                  default: 0, null: false
  end

  add_index "test_payloads", ["api_id"], name: "index_test_payloads_on_api_id", unique: true, using: :btree
  add_index "test_payloads", ["runner_id"], name: "test_payloads_user_id_fk", using: :btree
  add_index "test_payloads", ["state"], name: "index_test_payloads_on_state", using: :btree

  create_table "test_payloads_reports", id: false, force: true do |t|
    t.integer "test_payload_id", null: false
    t.integer "test_report_id",  null: false
  end

  add_index "test_payloads_reports", ["test_payload_id", "test_report_id"], name: "index_test_payloads_reports_on_payload_and_report_id", unique: true, using: :btree

  create_table "test_reports", force: true do |t|
    t.string   "api_id",     limit: 12, null: false
    t.integer  "runner_id",             null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "test_reports_results", id: false, force: true do |t|
    t.integer "test_report_id", null: false
    t.integer "test_result_id", null: false
  end

  add_index "test_reports_results", ["test_report_id", "test_result_id"], name: "index_test_reports_results_on_test_report_id_and_test_result_id", unique: true, using: :btree

  create_table "test_result_contributors", id: false, force: true do |t|
    t.integer "test_result_id"
    t.integer "email_id"
  end

  add_index "test_result_contributors", ["test_result_id", "email_id"], name: "index_test_contributors_on_result_and_email", unique: true, using: :btree

  create_table "test_results", force: true do |t|
    t.boolean  "passed",                                 null: false
    t.integer  "runner_id",                              null: false
    t.integer  "test_id"
    t.datetime "created_at",                             null: false
    t.datetime "run_at",                                 null: false
    t.integer  "duration",                               null: false
    t.text     "message"
    t.boolean  "active",                 default: true,  null: false
    t.integer  "project_version_id",                     null: false
    t.boolean  "new_test"
    t.integer  "category_id"
    t.integer  "test_payload_id",                        null: false
    t.integer  "key_id"
    t.string   "name"
    t.integer  "payload_properties_set", default: 0,     null: false
    t.boolean  "processed",              default: false, null: false
  end

  add_index "test_results", ["category_id"], name: "test_results_category_id_fk", using: :btree
  add_index "test_results", ["project_version_id"], name: "test_results_project_version_id_fk", using: :btree
  add_index "test_results", ["runner_id"], name: "test_results_runner_id_fk", using: :btree
  add_index "test_results", ["test_id"], name: "test_results_test_info_id_fk", using: :btree
  add_index "test_results", ["test_payload_id", "key_id"], name: "index_test_results_on_test_payload_id_and_key_id", unique: true, using: :btree

  create_table "test_results_tickets", id: false, force: true do |t|
    t.integer "test_result_id", null: false
    t.integer "ticket_id",      null: false
  end

  add_index "test_results_tickets", ["test_result_id", "ticket_id"], name: "index_test_results_tickets_on_test_result_id_and_ticket_id", unique: true, using: :btree

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
    t.integer  "user_id"
  end

  add_index "user_settings", ["last_test_key_project_id"], name: "user_settings_last_test_key_project_id_fk", using: :btree
  add_index "user_settings", ["user_id"], name: "index_user_settings_on_user_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                                           null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "sign_in_count",                   default: 0
    t.integer  "roles_mask",                      default: 0,    null: false
    t.boolean  "active",                          default: true, null: false
    t.integer  "email_id"
    t.string   "password_digest",                                null: false
    t.integer  "last_test_payload_id"
    t.string   "api_id",               limit: 12,                null: false
  end

  add_index "users", ["email_id"], name: "index_users_on_email_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree

  add_foreign_key "project_tests", "projects", name: "project_tests_project_id_fk"
  add_foreign_key "project_tests", "test_keys", name: "project_tests_key_id_fk", column: "key_id"

  add_foreign_key "project_versions", "projects", name: "project_versions_project_id_fk"

  add_foreign_key "tags_test_descriptions", "tags", name: "tags_test_descriptions_tag_id_fk"
  add_foreign_key "tags_test_descriptions", "test_descriptions", name: "tags_test_descriptions_test_description_id_fk"

  add_foreign_key "tags_test_results", "tags", name: "tags_test_results_tag_id_fk"
  add_foreign_key "tags_test_results", "test_results", name: "tags_test_results_test_result_id_fk"

  add_foreign_key "test_contributors", "emails", name: "test_contributors_email_id_fk"
  add_foreign_key "test_contributors", "test_descriptions", name: "test_contributors_test_description_id_fk"

  add_foreign_key "test_custom_values_descriptions", "test_custom_values", name: "test_custom_values_descriptions_test_custom_value_id_fk"
  add_foreign_key "test_custom_values_descriptions", "test_descriptions", name: "test_custom_values_descriptions_test_description_id_fk"

  add_foreign_key "test_custom_values_results", "test_custom_values", name: "test_custom_values_results_test_custom_value_id_fk"
  add_foreign_key "test_custom_values_results", "test_results", name: "test_custom_values_results_test_result_id_fk"

  add_foreign_key "test_descriptions", "categories", name: "test_descriptions_category_id_fk"
  add_foreign_key "test_descriptions", "project_tests", name: "test_descriptions_test_id_fk", column: "test_id"
  add_foreign_key "test_descriptions", "project_versions", name: "test_descriptions_project_version_id_fk"
  add_foreign_key "test_descriptions", "test_results", name: "test_descriptions_last_result_id_fk", column: "last_result_id"
  add_foreign_key "test_descriptions", "users", name: "test_descriptions_last_runner_id_fk", column: "last_runner_id"

  add_foreign_key "test_descriptions_tickets", "test_descriptions", name: "test_descriptions_tickets_test_description_id_fk"
  add_foreign_key "test_descriptions_tickets", "tickets", name: "test_descriptions_tickets_ticket_id_fk"

  add_foreign_key "test_keys", "projects", name: "test_keys_project_id_fk"
  add_foreign_key "test_keys", "users", name: "test_keys_user_id_fk"

  add_foreign_key "test_keys_payloads", "test_keys", name: "test_keys_payloads_test_key_id_fk"
  add_foreign_key "test_keys_payloads", "test_payloads", name: "test_keys_payloads_test_payload_id_fk", dependent: :delete

  add_foreign_key "test_payloads", "project_versions", name: "test_payloads_project_version_id_fk"
  add_foreign_key "test_payloads", "users", name: "test_payloads_user_id_fk", column: "runner_id"

  add_foreign_key "test_payloads_reports", "test_payloads", name: "test_payloads_reports_test_payload_id_fk"
  add_foreign_key "test_payloads_reports", "test_reports", name: "test_payloads_reports_test_report_id_fk"

  add_foreign_key "test_reports", "users", name: "test_reports_runner_id_fk", column: "runner_id"

  add_foreign_key "test_reports_results", "test_reports", name: "test_reports_results_test_report_id_fk"
  add_foreign_key "test_reports_results", "test_results", name: "test_reports_results_test_result_id_fk"

  add_foreign_key "test_result_contributors", "emails", name: "test_result_contributors_email_id_fk"
  add_foreign_key "test_result_contributors", "test_results", name: "test_result_contributors_test_result_id_fk"

  add_foreign_key "test_results", "categories", name: "test_results_category_id_fk"
  add_foreign_key "test_results", "project_tests", name: "test_results_test_id_fk", column: "test_id"
  add_foreign_key "test_results", "project_versions", name: "test_results_project_version_id_fk"
  add_foreign_key "test_results", "test_keys", name: "test_results_key_id_fk", column: "key_id"
  add_foreign_key "test_results", "test_payloads", name: "test_results_test_payload_id_fk"
  add_foreign_key "test_results", "users", name: "test_results_runner_id_fk", column: "runner_id"

  add_foreign_key "test_results_tickets", "test_results", name: "test_results_tickets_test_result_id_fk"
  add_foreign_key "test_results_tickets", "tickets", name: "test_results_tickets_ticket_id_fk"

  add_foreign_key "user_settings", "projects", name: "user_settings_last_test_key_project_id_fk", column: "last_test_key_project_id"
  add_foreign_key "user_settings", "users", name: "user_settings_user_id_fk"

  add_foreign_key "users", "emails", name: "users_email_id_fk"
  add_foreign_key "users", "test_payloads", name: "users_last_test_payload_id_fk", column: "last_test_payload_id"

end
