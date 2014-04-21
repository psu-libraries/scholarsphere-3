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

ActiveRecord::Schema.define(version: 20140117161959) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",     null: false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
  end

  create_table "checksum_audit_logs", force: true do |t|
    t.string   "pid"
    t.string   "dsid"
    t.string   "version"
    t.integer  "pass"
    t.string   "expected_result"
    t.string   "actual_result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checksum_audit_logs", ["pid", "dsid"], name: "by_pid_and_dsid"

  create_table "conversations", force: true do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "domain_terms", force: true do |t|
    t.string "model"
    t.string "term"
  end

  add_index "domain_terms", ["model", "term"], name: "terms_by_model_and_term"

  create_table "domain_terms_local_authorities", id: false, force: true do |t|
    t.integer "domain_term_id"
    t.integer "local_authority_id"
  end

  add_index "domain_terms_local_authorities", ["domain_term_id", "local_authority_id"], name: "domain_terms_by_domain_term_id_and_local_authority", unique: true
  add_index "domain_terms_local_authorities", ["domain_term_id", "local_authority_id"], name: "dtla_by_ids2"
  add_index "domain_terms_local_authorities", ["local_authority_id", "domain_term_id"], name: "dtla_by_ids1"

  create_table "follows", force: true do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows"

  create_table "local_authorities", force: true do |t|
    t.string "name"
  end

  create_table "local_authority_entries", force: true do |t|
    t.integer "local_authority_id"
    t.string  "label"
    t.string  "uri"
  end

  add_index "local_authority_entries", ["local_authority_id", "label"], name: "entries_by_term_and_label"
  add_index "local_authority_entries", ["local_authority_id", "uri"], name: "entries_by_term_and_uri"

  create_table "notifications", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id"

  create_table "proxy_deposit_requests", force: true do |t|
    t.string   "pid",                                   null: false
    t.integer  "sending_user_id",                       null: false
    t.integer  "receiving_user_id",                     null: false
    t.datetime "fulfillment_date"
    t.string   "status",            default: "pending", null: false
    t.text     "sender_comment"
    t.text     "receiver_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxy_deposit_requests", ["receiving_user_id"], name: "index_proxy_deposit_requests_on_receiving_user_id"
  add_index "proxy_deposit_requests", ["sending_user_id"], name: "index_proxy_deposit_requests_on_sending_user_id"

  create_table "proxy_deposit_rights", force: true do |t|
    t.integer  "grantor_id"
    t.integer  "grantee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxy_deposit_rights", ["grantee_id"], name: "index_proxy_deposit_rights_on_grantee_id"
  add_index "proxy_deposit_rights", ["grantor_id"], name: "index_proxy_deposit_rights_on_grantor_id"

  create_table "receipts", force: true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id"

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "single_use_links", force: true do |t|
    t.string   "downloadKey"
    t.string   "path"
    t.string   "itemId"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_local_authority_entries", force: true do |t|
    t.string   "label"
    t.string   "lowerLabel"
    t.string   "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_local_authority_entries", ["lowerLabel"], name: "entries_by_lower_label"

  create_table "superusers", force: true do |t|
    t.integer "user_id", null: false
  end

  create_table "trophies", force: true do |t|
    t.integer  "user_id"
    t.string   "generic_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              default: ""
    t.string   "encrypted_password",                 default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                              default: "", null: false
    t.string   "display_name"
    t.string   "address"
    t.string   "admin_area"
    t.string   "department"
    t.string   "title"
    t.string   "office"
    t.string   "chat_id"
    t.string   "website"
    t.string   "affiliation"
    t.string   "telephone"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "group_list"
    t.datetime "groups_last_update"
    t.boolean  "ldap_available"
    t.datetime "ldap_last_update"
    t.string   "facebook_handle"
    t.string   "twitter_handle"
    t.string   "googleplus_handle"
    t.string   "linkedin_handle"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "version_committers", force: true do |t|
    t.string   "obj_id"
    t.string   "datastream_id"
    t.string   "version_id"
    t.string   "committer_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
