# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_12_102031) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "vector"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "instagram"
    t.string "tiktok"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.bigint "organization_id"
    t.index ["discarded_at"], name: "index_brands_on_discarded_at"
    t.index ["organization_id"], name: "index_brands_on_organization_id"
  end

  create_table "bulk_influencers", force: :cascade do |t|
    t.integer "total_row"
    t.integer "current_row"
    t.string "error_messages", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_error"
    t.datetime "cancelled_at"
    t.string "job_id"
  end

  create_table "bulk_publications", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.integer "total_row", default: 0
    t.integer "current_row", default: 0
    t.string "error_messages", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cancelled_at"
    t.string "job_id"
    t.integer "total_error", default: 0
    t.index ["campaign_id"], name: "index_bulk_publications_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "brand_id", null: false
    t.integer "status"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "budget", default: 0
    t.integer "kpi_reach", default: 0
    t.integer "kpi_impression", default: 0
    t.float "kpi_engagement_rate"
    t.integer "kpi_cpv", default: 0
    t.integer "kpi_cpr", default: 0
    t.integer "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "kpi_number_of_social_media_accounts"
    t.string "mediarumu_pic_name"
    t.string "mediarumu_pic_phone"
    t.text "notes_and_media_terms"
    t.text "payment_terms"
    t.string "client_sign_name"
    t.integer "selected_media_plan_id"
    t.decimal "management_fees"
    t.datetime "invitation_expired_at"
    t.boolean "show_rate_price_story", default: true
    t.boolean "show_rate_price_story_session", default: true
    t.boolean "show_rate_price_feed_photo", default: true
    t.boolean "show_rate_price_feed_video", default: true
    t.boolean "show_rate_price_reel", default: true
    t.boolean "show_rate_price_live", default: true
    t.boolean "show_rate_price_owning_asset", default: true
    t.boolean "show_rate_price_tap_link", default: true
    t.boolean "show_rate_price_link_in_bio", default: true
    t.boolean "show_rate_price_live_attendance", default: true
    t.boolean "show_rate_price_host", default: true
    t.boolean "show_rate_price_comment", default: true
    t.boolean "show_rate_price_photoshoot", default: true
    t.boolean "show_rate_price_other", default: true
    t.integer "comments_count", default: 0
    t.integer "likes_count", default: 0
    t.integer "share_count", default: 0
    t.integer "impressions", default: 0
    t.integer "reach", default: 0
    t.float "engagement_rate", default: 0.0
    t.integer "budget_from_brand", default: 0
    t.integer "kpi_cpe", default: 0
    t.text "keyword"
    t.text "hashtag"
    t.bigint "media_comments_count", default: 0, null: false
    t.bigint "related_media_comments_count", default: 0, null: false
    t.decimal "kpi_crb", default: "0.0", null: false
    t.json "updated_target_plan_for_reach"
    t.string "comment_ai_prompt"
    t.text "comment_ai_analysis"
    t.text "comment_ai_payload_result"
    t.json "word_cloud"
    t.text "word_cloud_payload_result"
    t.bigint "organization_id"
    t.index ["brand_id"], name: "index_campaigns_on_brand_id"
    t.index ["discarded_at"], name: "index_campaigns_on_discarded_at"
    t.index ["organization_id"], name: "index_campaigns_on_organization_id"
  end

  create_table "campaigns_competitor_reviews", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "competitor_review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaigns_competitor_reviews_on_campaign_id"
    t.index ["competitor_review_id"], name: "index_campaigns_competitor_reviews_on_competitor_review_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_social_media_accounts", id: false, force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "social_media_account_id", null: false
  end

  create_table "competitor_reviews", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_competitor_reviews_on_organization_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "influencers", force: :cascade do |t|
    t.string "name"
    t.string "pic_phone_number"
    t.string "pic"
    t.integer "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "no_ktp"
    t.string "no_npwp"
    t.string "bank_code"
    t.string "account_number"
    t.text "address"
    t.string "phone_number"
    t.string "email"
    t.boolean "have_npwp", default: true
    t.index ["discarded_at"], name: "index_influencers_on_discarded_at"
  end

  create_table "managements", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "no_ktp"
    t.string "no_npwp"
    t.string "bank_code"
    t.string "account_number"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "pic_name"
    t.string "pic_email"
    t.index ["discarded_at"], name: "index_managements_on_discarded_at"
  end

  create_table "managements_accounts", force: :cascade do |t|
    t.bigint "management_id"
    t.bigint "social_media_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["management_id"], name: "index_managements_accounts_on_management_id"
    t.index ["social_media_account_id"], name: "index_managements_accounts_on_social_media_account_id"
  end

  create_table "media_comments", force: :cascade do |t|
    t.integer "platform"
    t.json "payload"
    t.boolean "related_to_brand"
    t.text "content"
    t.bigint "social_media_publication_id", null: false
    t.text "platform_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "comment_at"
    t.datetime "manually_reviewed_at"
    t.integer "sentiment_analysis", default: 0
    t.vector "embedding", limit: 1536
    t.index ["social_media_publication_id"], name: "index_media_comments_on_social_media_publication_id"
  end

  create_table "media_plans", force: :cascade do |t|
    t.string "name"
    t.integer "estimated_impression", default: 0
    t.integer "estimated_reach", default: 0
    t.float "estimated_engagement_rate", default: 0.0, null: false
    t.float "estimated_engagement_rate_branding_post", default: 0.0, null: false
    t.decimal "estimated_budget", default: "0.0", null: false
    t.bigint "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "scope_of_work_template"
    t.index ["campaign_id"], name: "index_media_plans_on_campaign_id"
  end

  create_table "media_plans_social_media_accounts", id: false, force: :cascade do |t|
    t.bigint "media_plan_id", null: false
    t.bigint "social_media_account_id", null: false
  end

  create_table "organization_settings", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_requests", force: :cascade do |t|
    t.integer "requestor_id"
    t.integer "beneficiary_id"
    t.string "beneficiary_type"
    t.integer "amount"
    t.date "due_date"
    t.integer "status"
    t.text "notes"
    t.bigint "campaign_id", null: false
    t.date "paid_at"
    t.integer "payer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pph_option", default: 1
    t.bigint "total_pph", default: 0
    t.boolean "ppn", default: false
    t.text "tax_invoice_number"
    t.bigint "total_ppn", default: 0
    t.bigint "total_payment", default: 0
    t.index ["campaign_id"], name: "index_payment_requests_on_campaign_id"
  end

  create_table "publication_associations", force: :cascade do |t|
    t.bigint "social_media_publication_id"
    t.string "associable_type"
    t.bigint "associable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["associable_type", "associable_id"], name: "index_publication_associations_on_associable"
    t.index ["social_media_publication_id", "associable_type", "associable_id"], name: "index_publication_associations_uniqueness", unique: true
    t.index ["social_media_publication_id"], name: "index_publication_associations_on_social_media_publication_id"
  end

  create_table "publication_histories", force: :cascade do |t|
    t.bigint "social_media_publication_id", null: false
    t.integer "likes_count"
    t.integer "comments_count"
    t.integer "impressions"
    t.integer "reach"
    t.float "engagement_rate"
    t.integer "share_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "social_media_account_id"
    t.integer "social_media_account_size"
    t.integer "platform"
    t.integer "campaign_id"
    t.integer "related_media_comments_count", default: 0
    t.bigint "saves_count", default: 0, null: false
    t.index ["social_media_publication_id"], name: "index_publication_histories_on_social_media_publication_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "scope_of_work_items", force: :cascade do |t|
    t.bigint "scope_of_work_id", null: false
    t.string "name"
    t.bigint "quantity", default: 0
    t.bigint "price", default: 0
    t.bigint "subtotal", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sell_price", default: 0
    t.bigint "subtotal_sell_price", default: 0
    t.datetime "posted_at"
    t.datetime "scheduled_at"
    t.index ["scope_of_work_id"], name: "index_scope_of_work_items_on_scope_of_work_id"
  end

  create_table "scope_of_works", force: :cascade do |t|
    t.bigint "media_plan_id", null: false
    t.bigint "social_media_account_id", null: false
    t.bigint "total"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.integer "total_sell_price"
    t.datetime "last_submitted_at"
    t.integer "status"
    t.integer "comments_count", default: 0
    t.integer "likes_count", default: 0
    t.integer "share_count", default: 0
    t.integer "impressions", default: 0
    t.integer "reach", default: 0
    t.float "engagement_rate", default: 0.0
    t.string "agreement_payment_terms_note"
    t.integer "agreement_maximum_payment_day"
    t.integer "agreement_absent_day"
    t.date "agreement_end_date"
    t.integer "budget_spent", default: 0
    t.integer "budget_spent_sell_price", default: 0
    t.bigint "management_id"
    t.index ["management_id"], name: "index_scope_of_works_on_management_id"
    t.index ["media_plan_id"], name: "index_scope_of_works_on_media_plan_id"
    t.index ["social_media_account_id"], name: "index_scope_of_works_on_social_media_account_id"
  end

  create_table "social_media_accounts", force: :cascade do |t|
    t.bigint "influencer_id", null: false
    t.string "username"
    t.integer "platform"
    t.integer "followers", default: 0
    t.bigint "story_price", default: 0
    t.bigint "story_session_price", default: 0
    t.bigint "feed_photo_price", default: 0
    t.bigint "feed_video_price", default: 0
    t.bigint "reel_price", default: 0
    t.bigint "live_price", default: 0
    t.bigint "owning_asset_price", default: 0
    t.datetime "last_sync_at"
    t.integer "estimated_impression", default: 0
    t.integer "estimated_reach", default: 0
    t.float "estimated_engagement_rate", default: 0.0
    t.float "estimated_engagement_rate_branding_post", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "platform_user_identifier"
    t.integer "kind"
    t.integer "size"
    t.datetime "discarded_at"
    t.float "estimated_engagement_rate_average", default: 0.0
    t.integer "tap_link_price", default: 0
    t.integer "link_in_bio_price", default: 0
    t.integer "live_attendance_price", default: 0
    t.bigint "host_price", default: 0
    t.bigint "comment_price", default: 0
    t.bigint "photoshoot_price", default: 0
    t.bigint "other_price", default: 0
    t.integer "estimated_likes_count"
    t.integer "estimated_comments_count"
    t.integer "estimated_share_count"
    t.index ["discarded_at"], name: "index_social_media_accounts_on_discarded_at"
    t.index ["influencer_id"], name: "index_social_media_accounts_on_influencer_id"
  end

  create_table "social_media_publications", force: :cascade do |t|
    t.string "post_identifier"
    t.integer "platform"
    t.integer "kind"
    t.string "url"
    t.datetime "post_created_at"
    t.text "caption"
    t.integer "comments_count"
    t.integer "likes_count"
    t.integer "share_count"
    t.integer "impressions"
    t.integer "reach"
    t.float "engagement_rate"
    t.datetime "last_sync_at"
    t.jsonb "payload"
    t.bigint "social_media_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "campaign_id"
    t.bigint "scope_of_work_id"
    t.integer "scope_of_work_item_id"
    t.boolean "manual", default: false
    t.bigint "media_comments_count", default: 0, null: false
    t.bigint "related_media_comments_count", default: 0, null: false
    t.string "last_error_during_sync"
    t.text "additional_info"
    t.boolean "deleted_by_third_party", default: false
    t.bigint "saves_count", default: 0, null: false
    t.string "last_comment_cursor"
    t.index ["campaign_id"], name: "index_social_media_publications_on_campaign_id"
    t.index ["scope_of_work_id"], name: "index_social_media_publications_on_scope_of_work_id"
    t.index ["social_media_account_id"], name: "index_social_media_publications_on_social_media_account_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tracked_requests_by_day_page", force: :cascade do |t|
    t.date "day", null: false
    t.bigint "total", default: 1, null: false
    t.string "url_hostname", null: false
    t.string "url_path", null: false
    t.string "referrer_hostname"
    t.string "referrer_path"
    t.index ["day"], name: "index_tracked_requests_by_day_page_on_day"
  end

  create_table "tracked_requests_by_day_site", force: :cascade do |t|
    t.date "day", null: false
    t.bigint "total", default: 1, null: false
    t.string "url_hostname", null: false
    t.string "platform"
    t.string "browser_engine"
    t.string "user_email"
    t.index ["day"], name: "index_tracked_requests_by_day_site_on_day"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "deactivated_at"
    t.bigint "organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "brands", "organizations"
  add_foreign_key "bulk_publications", "campaigns"
  add_foreign_key "campaigns", "brands"
  add_foreign_key "campaigns", "organizations"
  add_foreign_key "competitor_reviews", "organizations"
  add_foreign_key "media_comments", "social_media_publications"
  add_foreign_key "payment_requests", "campaigns"
  add_foreign_key "publication_histories", "social_media_publications"
  add_foreign_key "scope_of_work_items", "scope_of_works"
  add_foreign_key "scope_of_works", "managements"
  add_foreign_key "scope_of_works", "media_plans"
  add_foreign_key "scope_of_works", "social_media_accounts"
  add_foreign_key "social_media_accounts", "influencers"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "organizations"
end
