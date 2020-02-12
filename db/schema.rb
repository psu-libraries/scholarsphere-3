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

ActiveRecord::Schema.define(version: 20200211210706) do

  create_table "bookmarks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
    t.string "document_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "user_type"
    t.string "document_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "checksum_audit_logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "file_set_id"
    t.string "file_id"
    t.string "version"
    t.integer "pass"
    t.string "expected_result"
    t.string "actual_result"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["file_set_id", "file_id"], name: "by_pid_and_dsid"
  end

  create_table "content_blocks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "external_key"
  end

  create_table "curation_concerns_operations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "status"
    t.string "operation_type"
    t.string "job_class"
    t.string "job_id"
    t.string "type"
    t.text "message"
    t.integer "user_id"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lft"], name: "index_curation_concerns_operations_on_lft"
    t.index ["parent_id"], name: "index_curation_concerns_operations_on_parent_id"
    t.index ["rgt"], name: "index_curation_concerns_operations_on_rgt"
    t.index ["user_id"], name: "index_curation_concerns_operations_on_user_id"
  end

  create_table "featured_works", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order", default: 5
    t.string "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["order"], name: "index_featured_works_on_order"
    t.index ["work_id"], name: "index_featured_works_on_work_id"
  end

  create_table "file_download_stats", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "date"
    t.integer "downloads"
    t.string "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["file_id"], name: "index_file_download_stats_on_file_id"
    t.index ["user_id"], name: "index_file_download_stats_on_user_id"
  end

  create_table "file_view_stats", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "date"
    t.integer "views"
    t.string "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["file_id"], name: "index_file_view_stats_on_file_id"
    t.index ["user_id"], name: "index_file_view_stats_on_user_id"
  end

  create_table "follows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "followable_type", null: false
    t.integer "followable_id", null: false
    t.string "follower_type", null: false
    t.integer "follower_id", null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["followable_id", "followable_type"], name: "fk_followables"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
  end

  create_table "mailboxer_conversation_opt_outs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "unsubscriber_type"
    t.integer "unsubscriber_id"
    t.integer "conversation_id"
    t.index ["conversation_id"], name: "mb_opt_outs_on_conversations_id"
  end

  create_table "mailboxer_conversations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "subject", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailboxer_notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type"
    t.text "body"
    t.string "subject", default: ""
    t.string "sender_type"
    t.integer "sender_id"
    t.integer "conversation_id"
    t.boolean "draft", default: false
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.string "notified_object_type"
    t.integer "notified_object_id"
    t.string "notification_code"
    t.string "attachment"
    t.index ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id"
  end

  create_table "mailboxer_receipts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "receiver_type"
    t.integer "receiver_id"
    t.integer "notification_id", null: false
    t.boolean "is_read", default: false
    t.boolean "trashed", default: false
    t.boolean "deleted", default: false
    t.string "mailbox_type", limit: 25
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_mailboxer_receipts_on_notification_id"
  end

  create_table "migrate_audits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "f3_pid"
    t.string "f3_model"
    t.string "f3_title"
    t.string "f4_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
  end

  create_table "migration_resources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "pid"
    t.string "model"
    t.string "client_status"
    t.string "client_message"
    t.string "exception"
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "minter_states", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "namespace", default: "default", null: false
    t.string "template", null: false
    t.text "counters"
    t.bigint "seq", default: 0
    t.binary "rand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["namespace"], name: "index_minter_states_on_namespace", unique: true
  end

  create_table "permission_template_accesses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "permission_template_id"
    t.string "agent_type"
    t.string "agent_id"
    t.string "access"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["permission_template_id"], name: "fk_rails_9c1ccdc6d5"
  end

  create_table "permission_templates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "admin_set_id"
    t.string "visibility"
    t.string "workflow_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "release_date"
    t.string "release_period"
    t.index ["admin_set_id"], name: "index_permission_templates_on_admin_set_id"
  end

  create_table "proxy_deposit_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "work_id", null: false
    t.integer "sending_user_id", null: false
    t.integer "receiving_user_id", null: false
    t.datetime "fulfillment_date"
    t.string "status", default: "pending", null: false
    t.text "sender_comment"
    t.text "receiver_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["receiving_user_id"], name: "index_proxy_deposit_requests_on_receiving_user_id"
    t.index ["sending_user_id"], name: "index_proxy_deposit_requests_on_sending_user_id"
  end

  create_table "proxy_deposit_rights", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "grantor_id"
    t.integer "grantee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["grantee_id"], name: "index_proxy_deposit_rights_on_grantee_id"
    t.index ["grantor_id"], name: "index_proxy_deposit_rights_on_grantor_id"
  end

  create_table "qa_local_authorities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_qa_local_authorities_on_name", unique: true
  end

  create_table "qa_local_authority_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "local_authority_id"
    t.string "label"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "lower_label", type: :string, limit: 256, as: "lower(`label`)"
    t.index ["local_authority_id"], name: "index_qa_local_authority_entries_on_local_authority_id"
    t.index ["lower_label", "local_authority_id"], name: "index_qa_local_authority_entries_on_lower_label_and_authority"
    t.index ["uri"], name: "index_qa_local_authority_entries_on_uri", unique: true
  end

  create_table "queued_files", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "work_id"
    t.string "file_id"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "query_params"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "user_type"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "single_use_links", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "downloadKey"
    t.string "path"
    t.string "itemId"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sipity_agents", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "proxy_for_id", null: false
    t.string "proxy_for_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_id", "proxy_for_type"], name: "sipity_agents_proxy_for", unique: true
  end

  create_table "sipity_comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "entity_id", null: false
    t.integer "agent_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_sipity_comments_on_agent_id"
    t.index ["created_at"], name: "index_sipity_comments_on_created_at"
    t.index ["entity_id"], name: "index_sipity_comments_on_entity_id"
  end

  create_table "sipity_entities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "proxy_for_global_id", null: false
    t.integer "workflow_id", null: false
    t.integer "workflow_state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_global_id"], name: "sipity_entities_proxy_for_global_id", unique: true
    t.index ["workflow_id"], name: "index_sipity_entities_on_workflow_id"
    t.index ["workflow_state_id"], name: "index_sipity_entities_on_workflow_state_id"
  end

  create_table "sipity_entity_specific_responsibilities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "workflow_role_id", null: false
    t.string "entity_id", null: false
    t.integer "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "sipity_entity_specific_responsibilities_agent"
    t.index ["entity_id"], name: "sipity_entity_specific_responsibilities_entity"
    t.index ["workflow_role_id", "entity_id", "agent_id"], name: "sipity_entity_specific_responsibilities_aggregate", unique: true
    t.index ["workflow_role_id"], name: "sipity_entity_specific_responsibilities_role"
  end

  create_table "sipity_notifiable_contexts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "scope_for_notification_id", null: false
    t.string "scope_for_notification_type", null: false
    t.string "reason_for_notification", null: false
    t.integer "notification_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "sipity_notifiable_contexts_notification_id"
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification", "notification_id"], name: "sipity_notifiable_contexts_concern_surrogate", unique: true
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification"], name: "sipity_notifiable_contexts_concern_context"
    t.index ["scope_for_notification_id", "scope_for_notification_type"], name: "sipity_notifiable_contexts_concern"
  end

  create_table "sipity_notification_recipients", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "notification_id", null: false
    t.integer "role_id", null: false
    t.string "recipient_strategy", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id", "role_id", "recipient_strategy"], name: "sipity_notifications_recipients_surrogate"
    t.index ["notification_id"], name: "sipity_notification_recipients_notification"
    t.index ["recipient_strategy"], name: "sipity_notification_recipients_recipient_strategy"
    t.index ["role_id"], name: "sipity_notification_recipients_role"
  end

  create_table "sipity_notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "notification_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_notifications_on_name", unique: true
    t.index ["notification_type"], name: "index_sipity_notifications_on_notification_type"
  end

  create_table "sipity_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_roles_on_name", unique: true
  end

  create_table "sipity_workflow_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "workflow_id", null: false
    t.integer "resulting_workflow_state_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resulting_workflow_state_id"], name: "sipity_workflow_actions_resulting_workflow_state"
    t.index ["workflow_id", "name"], name: "sipity_workflow_actions_aggregate", unique: true
    t.index ["workflow_id"], name: "sipity_workflow_actions_workflow"
  end

  create_table "sipity_workflow_methods", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "service_name", null: false
    t.integer "weight", null: false
    t.integer "workflow_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_action_id"], name: "index_sipity_workflow_methods_on_workflow_action_id"
  end

  create_table "sipity_workflow_responsibilities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "agent_id", null: false
    t.integer "workflow_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "workflow_role_id"], name: "sipity_workflow_responsibilities_aggregate", unique: true
  end

  create_table "sipity_workflow_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "workflow_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_id", "role_id"], name: "sipity_workflow_roles_aggregate", unique: true
  end

  create_table "sipity_workflow_state_action_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "workflow_role_id", null: false
    t.integer "workflow_state_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_role_id", "workflow_state_action_id"], name: "sipity_workflow_state_action_permissions_aggregate", unique: true
  end

  create_table "sipity_workflow_state_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "originating_workflow_state_id", null: false
    t.integer "workflow_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["originating_workflow_state_id", "workflow_action_id"], name: "sipity_workflow_state_actions_aggregate", unique: true
  end

  create_table "sipity_workflow_states", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "workflow_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_workflow_states_on_name"
    t.index ["workflow_id", "name"], name: "sipity_type_state_aggregate", unique: true
  end

  create_table "sipity_workflows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "label"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allows_access_grant"
    t.index ["name"], name: "index_sipity_workflows_on_name", unique: true
  end

  create_table "sufia_features", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "superusers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
  end

  create_table "tinymce_assets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trophies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploaded_files", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "file"
    t.integer "user_id"
    t.string "file_set_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_set_uri"], name: "index_uploaded_files_on_file_set_uri"
    t.index ["user_id"], name: "index_uploaded_files_on_user_id"
  end

  create_table "user_stats", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.datetime "date"
    t.integer "file_views"
    t.integer "file_downloads"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "work_views"
    t.index ["user_id"], name: "index_user_stats_on_user_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "login", default: "", null: false
    t.string "display_name"
    t.string "address"
    t.string "admin_area"
    t.string "department"
    t.string "title"
    t.string "office"
    t.string "chat_id"
    t.string "website"
    t.string "affiliation"
    t.string "telephone"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text "group_list"
    t.datetime "groups_last_update"
    t.boolean "ldap_available"
    t.datetime "ldap_last_update"
    t.string "facebook_handle"
    t.string "twitter_handle"
    t.string "googleplus_handle"
    t.string "linkedin_handle"
    t.string "orcid"
    t.boolean "system_created", default: false
    t.boolean "logged_in", default: true
    t.string "arkivo_token"
    t.string "arkivo_subscription"
    t.binary "zotero_token"
    t.string "zotero_userid"
    t.boolean "guest", default: false
    t.boolean "opt_out_stats_email", default: false
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "version_committers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "obj_id"
    t.string "datastream_id"
    t.string "version_id"
    t.string "committer_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_view_stats", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "date"
    t.integer "work_views"
    t.string "work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_work_view_stats_on_user_id"
    t.index ["work_id"], name: "index_work_view_stats_on_work_id"
  end

  add_foreign_key "curation_concerns_operations", "users"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id_test"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "mailboxer_receipts_on_notification_id_test"
  add_foreign_key "permission_template_accesses", "permission_templates"
  add_foreign_key "qa_local_authority_entries", "qa_local_authorities", column: "local_authority_id"
  add_foreign_key "uploaded_files", "users"
end
