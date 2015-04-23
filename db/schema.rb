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

  create_table "app_settings", force: :cascade do |t|
    t.string   "ticketing_system_url",   limit: 255
    t.datetime "updated_at",                         null: false
    t.integer  "reports_cache_size",                 null: false
    t.integer  "tag_cloud_size",                     null: false
    t.integer  "test_outdated_days",                 null: false
    t.integer  "test_payloads_lifespan",             null: false
    t.integer  "test_runs_lifespan",                 null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",            limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.integer  "organization_id",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "emails", force: :cascade do |t|
    t.string "address", null: false
  end

  add_index "emails", ["address"], name: "index_emails_on_address", unique: true, using: :btree

  create_table "emails_users", id: false, force: :cascade do |t|
    t.integer "email_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "emails_users", ["email_id"], name: "index_emails_users_on_email_id", unique: true, using: :btree

  create_table "memberships", force: :cascade do |t|
    t.string   "api_id",                limit: 5,             null: false
    t.integer  "user_id",                                     null: false
    t.integer  "organization_email_id",                       null: false
    t.integer  "organization_id",                             null: false
    t.integer  "roles_mask",                      default: 0, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "memberships", ["api_id"], name: "index_memberships_on_api_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "api_id",          limit: 5,                  null: false
    t.string   "name",            limit: 50,                 null: false
    t.string   "display_name",    limit: 50
    t.string   "normalized_name", limit: 50,                 null: false
    t.boolean  "public_access",              default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "organizations", ["api_id"], name: "index_organizations_on_api_id", unique: true, using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  add_index "organizations", ["normalized_name"], name: "index_organizations_on_normalized_name", unique: true, using: :btree

  create_table "project_tests", force: :cascade do |t|
    t.string   "name",                      null: false
    t.integer  "key_id",                    null: false
    t.integer  "project_id",                null: false
    t.integer  "results_count", default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "project_tests", ["project_id", "key_id"], name: "index_project_tests_on_project_id_and_key_id", unique: true, using: :btree

  create_table "project_versions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "project_id",             null: false
    t.datetime "created_at",             null: false
  end

  add_index "project_versions", ["project_id", "name"], name: "index_project_versions_on_project_id_and_name", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                   limit: 50,             null: false
    t.string   "api_id",                 limit: 12,             null: false
    t.integer  "tests_count",                       default: 0, null: false
    t.integer  "deprecated_tests_count",            default: 0, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "description"
    t.integer  "organization_id",                               null: false
  end

  add_index "projects", ["api_id"], name: "index_projects_on_api_id", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",            limit: 50, null: false
    t.integer "organization_id",            null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tags_test_descriptions", id: false, force: :cascade do |t|
    t.integer "test_description_id", null: false
    t.integer "tag_id",              null: false
  end

  add_index "tags_test_descriptions", ["test_description_id", "tag_id"], name: "index_tags_test_descriptions_on_test_description_id_and_tag_id", unique: true, using: :btree

  create_table "tags_test_results", id: false, force: :cascade do |t|
    t.integer "test_result_id", null: false
    t.integer "tag_id",         null: false
  end

  add_index "tags_test_results", ["test_result_id", "tag_id"], name: "index_tags_test_results_on_test_result_id_and_tag_id", unique: true, using: :btree

  create_table "test_contributors", id: false, force: :cascade do |t|
    t.integer "test_description_id"
    t.integer "email_id"
  end

  add_index "test_contributors", ["test_description_id", "email_id"], name: "index_test_contributors_on_description_and_email", unique: true, using: :btree

  create_table "test_custom_values", force: :cascade do |t|
    t.string "name",     limit: 50, null: false
    t.text   "contents",            null: false
  end

  add_index "test_custom_values", ["name", "contents"], name: "index_test_custom_values_on_name_and_contents", unique: true, using: :btree

  create_table "test_custom_values_descriptions", id: false, force: :cascade do |t|
    t.integer "test_description_id",  null: false
    t.integer "test_custom_value_id", null: false
  end

  add_index "test_custom_values_descriptions", ["test_description_id", "test_custom_value_id"], name: "index_test_custom_values_descriptions_on_desc_and_value_ids", unique: true, using: :btree

  create_table "test_custom_values_results", id: false, force: :cascade do |t|
    t.integer "test_result_id",       null: false
    t.integer "test_custom_value_id", null: false
  end

  add_index "test_custom_values_results", ["test_result_id", "test_custom_value_id"], name: "index_test_custom_values_results_on_result_and_value_id", unique: true, using: :btree

  create_table "test_descriptions", force: :cascade do |t|
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

  create_table "test_descriptions_tickets", id: false, force: :cascade do |t|
    t.integer "test_description_id", null: false
    t.integer "ticket_id",           null: false
  end

  add_index "test_descriptions_tickets", ["test_description_id", "ticket_id"], name: "index_test_descriptions_on_description_and_ticket", unique: true, using: :btree

  create_table "test_keys", force: :cascade do |t|
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

  create_table "test_keys_payloads", id: false, force: :cascade do |t|
    t.integer "test_key_id",     null: false
    t.integer "test_payload_id", null: false
  end

  add_index "test_keys_payloads", ["test_key_id", "test_payload_id"], name: "index_test_keys_payloads_on_test_key_id_and_test_payload_id", unique: true, using: :btree
  add_index "test_keys_payloads", ["test_payload_id"], name: "test_keys_payloads_test_payload_id_fk", using: :btree

  create_table "test_payloads", force: :cascade do |t|
    t.integer  "contents_bytesize",                                    null: false
    t.string   "state",                         limit: 20,             null: false
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
    t.datetime "results_processed_at"
  end

  add_index "test_payloads", ["api_id"], name: "index_test_payloads_on_api_id", unique: true, using: :btree
  add_index "test_payloads", ["runner_id"], name: "test_payloads_user_id_fk", using: :btree
  add_index "test_payloads", ["state"], name: "index_test_payloads_on_state", using: :btree

  create_table "test_payloads_reports", id: false, force: :cascade do |t|
    t.integer "test_payload_id", null: false
    t.integer "test_report_id",  null: false
  end

  add_index "test_payloads_reports", ["test_payload_id", "test_report_id"], name: "index_test_payloads_reports_on_payload_and_report_id", unique: true, using: :btree

  create_table "test_reports", force: :cascade do |t|
    t.string   "api_id",          limit: 5, null: false
    t.integer  "organization_id",           null: false
    t.integer  "runner_id",                 null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "test_reports", ["api_id"], name: "index_test_reports_on_api_id", unique: true, using: :btree

  create_table "test_result_contributors", id: false, force: :cascade do |t|
    t.integer "test_result_id"
    t.integer "email_id"
  end

  add_index "test_result_contributors", ["test_result_id", "email_id"], name: "index_test_contributors_on_result_and_email", unique: true, using: :btree

  create_table "test_results", force: :cascade do |t|
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
    t.datetime "processed_at"
  end

  add_index "test_results", ["category_id"], name: "test_results_category_id_fk", using: :btree
  add_index "test_results", ["project_version_id"], name: "test_results_project_version_id_fk", using: :btree
  add_index "test_results", ["runner_id"], name: "test_results_runner_id_fk", using: :btree
  add_index "test_results", ["test_id"], name: "test_results_test_info_id_fk", using: :btree

  create_table "test_results_tickets", id: false, force: :cascade do |t|
    t.integer "test_result_id", null: false
    t.integer "ticket_id",      null: false
  end

  add_index "test_results_tickets", ["test_result_id", "ticket_id"], name: "index_test_results_tickets_on_test_result_id_and_ticket_id", unique: true, using: :btree

  create_table "tickets", force: :cascade do |t|
    t.string   "name",            limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organization_id",             null: false
  end

  add_index "tickets", ["name"], name: "index_tickets_on_name", unique: true, using: :btree

  create_table "user_settings", force: :cascade do |t|
    t.integer  "last_test_key_project_id"
    t.datetime "updated_at",               null: false
    t.integer  "last_test_key_number"
    t.integer  "user_id"
  end

  add_index "user_settings", ["last_test_key_project_id"], name: "user_settings_last_test_key_project_id_fk", using: :btree
  add_index "user_settings", ["user_id"], name: "index_user_settings_on_user_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                 limit: 255,                null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "sign_in_count",                    default: 0
    t.integer  "roles_mask",                       default: 0,    null: false
    t.boolean  "active",                           default: true, null: false
    t.integer  "primary_email_id"
    t.string   "password_digest",                                 null: false
    t.integer  "last_test_payload_id"
    t.string   "api_id",               limit: 5,                  null: false
  end

  add_index "users", ["api_id"], name: "index_users_on_api_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["primary_email_id"], name: "index_users_on_primary_email_id", unique: true, using: :btree

  add_foreign_key "categories", "organizations"
  add_foreign_key "emails_users", "emails"
  add_foreign_key "emails_users", "users"
  add_foreign_key "memberships", "emails", column: "organization_email_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "project_tests", "projects"
  add_foreign_key "project_tests", "test_keys", column: "key_id"
  add_foreign_key "project_versions", "projects", name: "project_versions_project_id_fk"
  add_foreign_key "projects", "organizations"
  add_foreign_key "tags", "organizations"
  add_foreign_key "tags_test_descriptions", "tags"
  add_foreign_key "tags_test_descriptions", "test_descriptions"
  add_foreign_key "tags_test_results", "tags"
  add_foreign_key "tags_test_results", "test_results"
  add_foreign_key "test_contributors", "emails"
  add_foreign_key "test_contributors", "test_descriptions"
  add_foreign_key "test_custom_values_descriptions", "test_custom_values"
  add_foreign_key "test_custom_values_descriptions", "test_descriptions"
  add_foreign_key "test_custom_values_results", "test_custom_values"
  add_foreign_key "test_custom_values_results", "test_results"
  add_foreign_key "test_descriptions", "categories"
  add_foreign_key "test_descriptions", "project_tests", column: "test_id"
  add_foreign_key "test_descriptions", "project_versions"
  add_foreign_key "test_descriptions", "test_results", column: "last_result_id"
  add_foreign_key "test_descriptions", "users", column: "last_runner_id"
  add_foreign_key "test_descriptions_tickets", "test_descriptions"
  add_foreign_key "test_descriptions_tickets", "tickets"
  add_foreign_key "test_keys", "projects", name: "test_keys_project_id_fk"
  add_foreign_key "test_keys", "users", name: "test_keys_user_id_fk"
  add_foreign_key "test_keys_payloads", "test_keys", name: "test_keys_payloads_test_key_id_fk"
  add_foreign_key "test_keys_payloads", "test_payloads", name: "test_keys_payloads_test_payload_id_fk", on_delete: :cascade
  add_foreign_key "test_payloads", "project_versions"
  add_foreign_key "test_payloads", "users", column: "runner_id", name: "test_payloads_user_id_fk"
  add_foreign_key "test_payloads_reports", "test_payloads"
  add_foreign_key "test_payloads_reports", "test_reports"
  add_foreign_key "test_reports", "organizations"
  add_foreign_key "test_reports", "users", column: "runner_id"
  add_foreign_key "test_result_contributors", "emails"
  add_foreign_key "test_result_contributors", "test_results"
  add_foreign_key "test_results", "categories", name: "test_results_category_id_fk"
  add_foreign_key "test_results", "project_tests", column: "test_id"
  add_foreign_key "test_results", "project_versions", name: "test_results_project_version_id_fk"
  add_foreign_key "test_results", "test_keys", column: "key_id"
  add_foreign_key "test_results", "test_payloads"
  add_foreign_key "test_results", "users", column: "runner_id", name: "test_results_runner_id_fk"
  add_foreign_key "test_results_tickets", "test_results"
  add_foreign_key "test_results_tickets", "tickets"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "user_settings", "projects", column: "last_test_key_project_id", name: "user_settings_last_test_key_project_id_fk"
  add_foreign_key "user_settings", "users"
  add_foreign_key "users", "emails", column: "primary_email_id"
  add_foreign_key "users", "test_payloads", column: "last_test_payload_id"
end
