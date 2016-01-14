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

ActiveRecord::Schema.define(version: 20160114085241) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_settings", force: :cascade do |t|
    t.datetime "updated_at",                                null: false
    t.boolean  "user_registration_enabled", default: false, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",            limit: 50, null: false
    t.integer  "organization_id",            null: false
    t.datetime "created_at",                 null: false
  end

  add_index "categories", ["name", "organization_id"], name: "index_categories_on_name_and_organization_id", unique: true, using: :btree

  create_table "emails", force: :cascade do |t|
    t.string  "address", limit: 255,                 null: false
    t.boolean "active",              default: false, null: false
    t.integer "user_id"
  end

  add_index "emails", ["address"], name: "index_emails_on_address", unique: true, using: :btree

  create_table "memberships", force: :cascade do |t|
    t.string   "api_id",                limit: 12,              null: false
    t.integer  "user_id"
    t.integer  "organization_email_id"
    t.integer  "organization_id",                               null: false
    t.integer  "roles_mask",                        default: 0, null: false
    t.string   "otp",                   limit: 255
    t.datetime "expires_at"
    t.datetime "accepted_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "memberships", ["api_id"], name: "index_memberships_on_api_id", unique: true, using: :btree
  add_index "memberships", ["otp"], name: "index_memberships_on_otp", unique: true, using: :btree
  add_index "memberships", ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "api_id",            limit: 5,                  null: false
    t.string   "name",              limit: 50,                 null: false
    t.string   "display_name",      limit: 50
    t.string   "normalized_name",   limit: 50,                 null: false
    t.boolean  "public_access",                default: false, null: false
    t.integer  "memberships_count",            default: 0,     null: false
    t.integer  "projects_count",               default: 0,     null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "active",                       default: false, null: false
  end

  add_index "organizations", ["api_id"], name: "index_organizations_on_api_id", unique: true, using: :btree
  add_index "organizations", ["normalized_name"], name: "index_organizations_on_normalized_name", unique: true, using: :btree

  create_table "project_tests", force: :cascade do |t|
    t.string   "name",            limit: 255,             null: false
    t.integer  "key_id"
    t.integer  "description_id"
    t.integer  "project_id",                              null: false
    t.integer  "results_count",               default: 0, null: false
    t.datetime "first_run_at",                            null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "first_runner_id"
    t.string   "api_id",          limit: 12,              null: false
  end

  add_index "project_tests", ["api_id"], name: "index_project_tests_on_api_id", unique: true, using: :btree
  add_index "project_tests", ["description_id"], name: "index_project_tests_on_description_id", unique: true, using: :btree
  add_index "project_tests", ["project_id", "key_id"], name: "index_project_tests_on_project_id_and_key_id", unique: true, using: :btree

  create_table "project_versions", force: :cascade do |t|
    t.string   "name",       limit: 100, null: false
    t.integer  "project_id",             null: false
    t.datetime "created_at",             null: false
  end

  add_index "project_versions", ["name", "project_id"], name: "index_project_versions_on_name_and_project_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "api_id",          limit: 12,             null: false
    t.string   "name",            limit: 50,             null: false
    t.string   "display_name",    limit: 50
    t.string   "normalized_name", limit: 50,             null: false
    t.text     "description"
    t.integer  "organization_id",                        null: false
    t.integer  "tests_count",                default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "last_report_id"
  end

  add_index "projects", ["api_id"], name: "index_projects_on_api_id", unique: true, using: :btree
  add_index "projects", ["normalized_name", "organization_id"], name: "index_projects_on_normalized_name_and_organization_id", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",            limit: 50, null: false
    t.integer  "organization_id",            null: false
    t.datetime "created_at",                 null: false
  end

  add_index "tags", ["name", "organization_id"], name: "index_tags_on_name_and_organization_id", unique: true, using: :btree

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

  create_table "test_contributions", force: :cascade do |t|
    t.string   "kind",                limit: 20, null: false
    t.integer  "test_description_id",            null: false
    t.integer  "user_id",                        null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "test_contributions", ["test_description_id", "user_id"], name: "index_test_contributions_on_test_description_id_and_user_id", unique: true, using: :btree

  create_table "test_descriptions", force: :cascade do |t|
    t.string   "name",               limit: 255,             null: false
    t.integer  "test_id",                                    null: false
    t.integer  "project_version_id",                         null: false
    t.integer  "category_id"
    t.boolean  "passing",                                    null: false
    t.boolean  "active",                                     null: false
    t.integer  "last_duration",                              null: false
    t.datetime "last_run_at",                                null: false
    t.integer  "last_runner_id",                             null: false
    t.integer  "last_result_id"
    t.integer  "results_count",                  default: 0, null: false
    t.json     "custom_values"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "test_descriptions", ["test_id", "project_version_id"], name: "index_test_descriptions_on_test_id_and_project_version_id", unique: true, using: :btree

  create_table "test_descriptions_tickets", id: false, force: :cascade do |t|
    t.integer "test_description_id", null: false
    t.integer "ticket_id",           null: false
  end

  add_index "test_descriptions_tickets", ["test_description_id", "ticket_id"], name: "index_test_descriptions_on_description_and_ticket", unique: true, using: :btree

  create_table "test_keys", force: :cascade do |t|
    t.string   "key",        limit: 50,                null: false
    t.boolean  "free",                  default: true, null: false
    t.integer  "project_id",                           null: false
    t.integer  "user_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "test_keys", ["key", "project_id"], name: "index_test_keys_on_key_and_project_id", unique: true, using: :btree

  create_table "test_keys_payloads", id: false, force: :cascade do |t|
    t.integer "test_key_id",     null: false
    t.integer "test_payload_id", null: false
  end

  add_index "test_keys_payloads", ["test_key_id", "test_payload_id"], name: "index_test_keys_payloads_on_test_key_id_and_test_payload_id", unique: true, using: :btree

  create_table "test_payloads", force: :cascade do |t|
    t.string   "api_id",                        limit: 36,             null: false
    t.string   "state",                         limit: 20,             null: false
    t.json     "contents",                                             null: false
    t.integer  "contents_bytesize",                                    null: false
    t.integer  "duration",                                 default: 0, null: false
    t.integer  "results_count",                            default: 0, null: false
    t.integer  "passed_results_count",                     default: 0, null: false
    t.integer  "inactive_results_count",                   default: 0, null: false
    t.integer  "inactive_passed_results_count",            default: 0, null: false
    t.text     "backtrace"
    t.integer  "runner_id",                                            null: false
    t.integer  "project_version_id"
    t.datetime "ended_at",                                             null: false
    t.datetime "received_at",                                          null: false
    t.datetime "processing_at"
    t.datetime "processed_at"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "tests_count",                              default: 0, null: false
    t.integer  "new_tests_count",                          default: 0, null: false
  end

  add_index "test_payloads", ["api_id"], name: "index_test_payloads_on_api_id", unique: true, using: :btree
  add_index "test_payloads", ["state"], name: "index_test_payloads_on_state", using: :btree

  create_table "test_payloads_reports", id: false, force: :cascade do |t|
    t.integer "test_payload_id", null: false
    t.integer "test_report_id",  null: false
  end

  add_index "test_payloads_reports", ["test_payload_id", "test_report_id"], name: "index_test_payloads_reports_on_payload_and_report_id", unique: true, using: :btree

  create_table "test_reports", force: :cascade do |t|
    t.string   "api_id",          limit: 12,  null: false
    t.string   "uid",             limit: 100
    t.integer  "organization_id",             null: false
    t.datetime "started_at",                  null: false
    t.datetime "ended_at",                    null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "test_reports", ["api_id"], name: "index_test_reports_on_api_id", unique: true, using: :btree
  add_index "test_reports", ["uid", "organization_id"], name: "index_test_reports_on_uid_and_organization_id", unique: true, using: :btree

  create_table "test_result_contributors", id: false, force: :cascade do |t|
    t.integer "test_result_id", null: false
    t.integer "email_id",       null: false
  end

  add_index "test_result_contributors", ["test_result_id", "email_id"], name: "index_test_contributors_on_result_and_email", unique: true, using: :btree

  create_table "test_results", force: :cascade do |t|
    t.string   "name",                   limit: 255,             null: false
    t.boolean  "passed",                                         null: false
    t.integer  "duration",                                       null: false
    t.text     "message"
    t.boolean  "active",                                         null: false
    t.boolean  "new_test",                                       null: false
    t.integer  "payload_properties_set",             default: 0, null: false
    t.json     "custom_values"
    t.integer  "runner_id",                                      null: false
    t.integer  "test_id"
    t.integer  "project_version_id",                             null: false
    t.integer  "test_payload_id",                                null: false
    t.integer  "key_id"
    t.integer  "category_id"
    t.datetime "run_at",                                         null: false
    t.datetime "created_at",                                     null: false
    t.integer  "payload_index",                                  null: false
  end

  add_index "test_results", ["test_payload_id", "payload_index"], name: "index_test_results_on_test_payload_id_and_payload_index", unique: true, using: :btree

  create_table "test_results_tickets", id: false, force: :cascade do |t|
    t.integer "test_result_id", null: false
    t.integer "ticket_id",      null: false
  end

  add_index "test_results_tickets", ["test_result_id", "ticket_id"], name: "index_test_results_tickets_on_test_result_id_and_ticket_id", unique: true, using: :btree

  create_table "tickets", force: :cascade do |t|
    t.string   "name",            limit: 50, null: false
    t.integer  "organization_id",            null: false
    t.datetime "created_at",                 null: false
  end

  add_index "tickets", ["name", "organization_id"], name: "index_tickets_on_name_and_organization_id", unique: true, using: :btree

  create_table "user_registrations", force: :cascade do |t|
    t.string   "api_id",          limit: 5,                   null: false
    t.string   "otp",             limit: 150
    t.datetime "expires_at"
    t.boolean  "completed",                   default: false, null: false
    t.datetime "completed_at"
    t.integer  "user_id",                                     null: false
    t.integer  "organization_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "user_registrations", ["api_id"], name: "index_user_registrations_on_api_id", unique: true, using: :btree
  add_index "user_registrations", ["otp"], name: "index_user_registrations_on_otp", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "api_id",           limit: 5,                  null: false
    t.string   "name",             limit: 25,                 null: false
    t.boolean  "active",                      default: false, null: false
    t.string   "password_digest",  limit: 60
    t.integer  "roles_mask",                  default: 0,     null: false
    t.integer  "primary_email_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "technical",                   default: false, null: false
  end

  add_index "users", ["api_id"], name: "index_users_on_api_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["primary_email_id"], name: "index_users_on_primary_email_id", unique: true, using: :btree

  add_foreign_key "categories", "organizations"
  add_foreign_key "emails", "users", on_delete: :nullify
  add_foreign_key "memberships", "emails", column: "organization_email_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "project_tests", "projects"
  add_foreign_key "project_tests", "test_descriptions", column: "description_id"
  add_foreign_key "project_tests", "test_keys", column: "key_id"
  add_foreign_key "project_tests", "users", column: "first_runner_id"
  add_foreign_key "project_versions", "projects"
  add_foreign_key "projects", "organizations"
  add_foreign_key "projects", "test_reports", column: "last_report_id"
  add_foreign_key "tags", "organizations"
  add_foreign_key "tags_test_descriptions", "tags"
  add_foreign_key "tags_test_descriptions", "test_descriptions"
  add_foreign_key "tags_test_results", "tags"
  add_foreign_key "tags_test_results", "test_results"
  add_foreign_key "test_contributions", "test_descriptions"
  add_foreign_key "test_contributions", "users"
  add_foreign_key "test_descriptions", "categories"
  add_foreign_key "test_descriptions", "project_tests", column: "test_id"
  add_foreign_key "test_descriptions", "project_versions"
  add_foreign_key "test_descriptions", "test_results", column: "last_result_id"
  add_foreign_key "test_descriptions", "users", column: "last_runner_id"
  add_foreign_key "test_descriptions_tickets", "test_descriptions"
  add_foreign_key "test_descriptions_tickets", "tickets"
  add_foreign_key "test_keys", "projects"
  add_foreign_key "test_keys", "users"
  add_foreign_key "test_keys_payloads", "test_keys"
  add_foreign_key "test_keys_payloads", "test_payloads"
  add_foreign_key "test_payloads", "project_versions"
  add_foreign_key "test_payloads", "users", column: "runner_id"
  add_foreign_key "test_payloads_reports", "test_payloads"
  add_foreign_key "test_payloads_reports", "test_reports"
  add_foreign_key "test_reports", "organizations"
  add_foreign_key "test_result_contributors", "emails"
  add_foreign_key "test_result_contributors", "test_results"
  add_foreign_key "test_results", "categories"
  add_foreign_key "test_results", "project_tests", column: "test_id"
  add_foreign_key "test_results", "project_versions"
  add_foreign_key "test_results", "test_keys", column: "key_id"
  add_foreign_key "test_results", "test_payloads"
  add_foreign_key "test_results", "users", column: "runner_id"
  add_foreign_key "test_results_tickets", "test_results"
  add_foreign_key "test_results_tickets", "tickets"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "user_registrations", "organizations"
  add_foreign_key "user_registrations", "users"
  add_foreign_key "users", "emails", column: "primary_email_id"
end
