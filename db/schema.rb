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

ActiveRecord::Schema[8.0].define(version: 2025_10_21_044027) do
  create_table "attachments", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.binary "data", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "banner_videos", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "campaign_id"
    t.datetime "interval_start"
    t.datetime "interval_end"
    t.decimal "total_basket_value", precision: 15, scale: 6
    t.decimal "total_budget", precision: 15, scale: 6
    t.integer "vast_video_width"
    t.integer "vast_video_height"
    t.decimal "bid_ecpm", precision: 15, scale: 6
    t.integer "vast_video_linerarity"
    t.integer "vast_video_duration"
    t.text "vast_video_type"
    t.text "vast_video_outgoing_file", size: :medium
    t.integer "bids"
    t.integer "clicks"
    t.integer "pixels"
    t.integer "wins"
    t.decimal "total_cost", precision: 15, scale: 6, default: "0.0"
    t.decimal "daily_cost", precision: 15, scale: 6
    t.decimal "daily_budget", precision: 15, scale: 6
    t.text "frequency_spec"
    t.integer "frequency_expire"
    t.integer "frequency_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "hourly_budget", precision: 15, scale: 6
    t.string "name"
    t.integer "target_id"
    t.decimal "hourly_cost", precision: 15, scale: 6
    t.integer "bitrate"
    t.string "mime_type"
    t.string "deals"
    t.string "width_range"
    t.string "height_range"
    t.string "width_height_list"
  end

  create_table "banner_videos_rtb_standards", id: false, charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "banner_video_id"
    t.integer "rtb_standard_id"
    t.index ["banner_video_id"], name: "index_banner_videos_rtb_standards_on_banner_video_id"
    t.index ["rtb_standard_id"], name: "index_banner_videos_rtb_standards_on_rtb_standard_id"
  end

  create_table "banners", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "campaign_id"
    t.datetime "interval_start", null: false
    t.datetime "interval_end"
    t.decimal "total_basket_value", precision: 15, scale: 6
    t.integer "width"
    t.integer "height"
    t.decimal "bid_ecpm", precision: 15, scale: 6
    t.decimal "total_cost", precision: 15, scale: 6
    t.string "contenttype", limit: 1024
    t.string "iurl", limit: 1024
    t.text "htmltemplate", size: :medium
    t.integer "bids"
    t.integer "clicks"
    t.integer "pixels"
    t.integer "wins"
    t.decimal "daily_budget", precision: 15, scale: 6
    t.decimal "hourly_budget", precision: 15, scale: 6
    t.decimal "daily_cost", precision: 15, scale: 6
    t.integer "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "frequency_spec"
    t.integer "frequency_expire"
    t.integer "frequency_count"
    t.decimal "hourly_cost", precision: 15, scale: 6
    t.string "deals"
    t.string "width_range"
    t.string "height_range"
    t.string "width_height_list"
  end

  create_table "banners_rtb_standards", id: false, charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "banner_id"
    t.integer "rtb_standard_id"
    t.index ["banner_id"], name: "index_banners_rtb_standards_on_banner_id"
    t.index ["rtb_standard_id"], name: "index_banners_rtb_standards_on_rtb_standard_id"
  end

  create_table "campaigns", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "activate_time"
    t.datetime "expire_time"
    t.decimal "cost", precision: 15, scale: 6
    t.string "ad_domain", limit: 1024
    t.integer "clicks"
    t.integer "pixels"
    t.integer "wins"
    t.integer "bids"
    t.string "name", limit: 1024
    t.string "status", limit: 1024
    t.string "conversion_type", limit: 1024
    t.decimal "budget_limit_daily", precision: 15, scale: 6
    t.decimal "budget_limit_hourly", precision: 15, scale: 6
    t.decimal "total_budget", precision: 15, scale: 6
    t.decimal "bid", precision: 15, scale: 6
    t.text "shard"
    t.text "forensiq"
    t.decimal "daily_cost", precision: 15, scale: 6
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.decimal "hourly_cost", precision: 15, scale: 6
    t.string "exchanges"
    t.string "regions"
    t.integer "target_id"
  end

  create_table "campaigns_rtb_standards", id: false, charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "rtb_standard_id"
    t.index ["campaign_id"], name: "index_campaigns_rtb_standards_on_campaign_id"
    t.index ["rtb_standard_id"], name: "index_campaigns_rtb_standards_on_rtb_standard_id"
  end

  create_table "categories", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", limit: 1024
    t.string "description", limit: 2048
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "categories_documents", id: false, charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "document_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_categories_documents_on_category_id"
    t.index ["document_id"], name: "index_categories_documents_on_document_id"
  end

  create_table "countries", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "sort_order"
    t.string "common_name"
    t.string "formal_name"
    t.string "country_type"
    t.string "sub_type"
    t.string "sovereignty"
    t.string "capital"
    t.string "iso_4217_currency_code"
    t.string "iso_4217_currency_name"
    t.string "iso_3166_1_2_letter_code"
    t.string "iso_3166_1_3_letter_code"
    t.string "iso_3166_1_number"
    t.string "iana_country_code_tld"
    t.string "itu_t_telephone_code"
  end

  create_table "credit_transactions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_type", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_type"], name: "index_credit_transactions_on_transaction_type"
    t.index ["user_id", "created_at"], name: "index_credit_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_credit_transactions_on_user_id"
  end

  create_table "documents", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", limit: 1024
    t.string "description", limit: 2048
    t.string "doctype", limit: 1024
    t.text "code"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "exchange_attributes", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "banner_id"
    t.integer "banner_video_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "exchange"
    t.index ["banner_id"], name: "index_exchange_attributes_on_banner_id"
    t.index ["banner_video_id"], name: "index_exchange_attributes_on_banner_video_id"
  end

  create_table "exchange_rtbspecs", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "rtbspecification", limit: 1024
    t.string "operand_type", limit: 1024
    t.string "operand_ordinal", limit: 1024
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "exchange_smarty_ads_rtbspecs", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "rtbspecification", limit: 1024
    t.string "operand_type", limit: 1024
    t.string "operand_ordinal", limit: 1024
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "iab_categories", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.text "group"
    t.text "name"
    t.text "iab_id"
    t.boolean "is_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", limit: 1024
    t.string "description", limit: 4096
    t.string "list_type", limit: 1024
    t.integer "filesize"
    t.string "s3_url", limit: 4096
    t.string "filepath", limit: 4096
    t.string "filetype", limit: 4096
    t.string "last_modified", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_commands", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", limit: 1024
    t.string "type", limit: 1024
    t.integer "campaign_id"
    t.string "description", limit: 2048
    t.text "command"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "banner_id"
    t.integer "banner_video_id"
  end

  create_table "rtb_standards", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "rtbspecification", limit: 1024
    t.string "operator", limit: 1024
    t.string "operand", limit: 1024
    t.string "operand_type", limit: 16
    t.string "operand_ordinal", limit: 16
    t.boolean "rtb_required"
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "operand_list_id"
  end

  create_table "stats_rtb", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.integer "campaign_id"
    t.datetime "stats_date"
    t.integer "bids"
    t.integer "wins"
    t.integer "clicks"
    t.integer "pixels"
    t.decimal "win_price", precision: 15, scale: 6
    t.decimal "bid_price", precision: 15, scale: 6
  end

  create_table "targets", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "activate_time"
    t.datetime "expire_time"
    t.text "list_of_domains", size: :medium
    t.string "domain_targetting", limit: 50
    t.float "geo_latitude", limit: 53
    t.float "geo_longitude", limit: 53
    t.float "geo_range", limit: 53
    t.text "country"
    t.text "geo_region"
    t.text "carrier"
    t.text "os"
    t.text "make"
    t.text "model"
    t.text "devicetype"
    t.text "IAB_category"
    t.text "IAB_category_blklist"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "domains_list_id"
  end

  create_table "users", charset: "utf8mb3", collation: "utf8mb3_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "subscription_status"
    t.string "subscription_plan"
    t.datetime "trial_ends_at"
    t.decimal "credits_balance", precision: 10, scale: 2, default: "0.0", null: false
  end

  add_foreign_key "credit_transactions", "users"
end
