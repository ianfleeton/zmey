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

ActiveRecord::Schema.define(version: 20141219142556) do

  create_table "additional_products", force: true do |t|
    t.integer  "product_id",            limit: 4,                 null: false
    t.integer  "additional_product_id", limit: 4,                 null: false
    t.boolean  "selected_by_default",   limit: 1, default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_products", ["product_id"], name: "index_additional_products_on_product_id", using: :btree

  create_table "addresses", force: true do |t|
    t.integer  "user_id",        limit: 4
    t.string   "full_name",      limit: 255, default: "", null: false
    t.string   "address_line_1", limit: 255, default: "", null: false
    t.string   "address_line_2", limit: 255
    t.string   "town_city",      limit: 255, default: "", null: false
    t.string   "county",         limit: 255
    t.string   "postcode",       limit: 255, default: "", null: false
    t.integer  "country_id",     limit: 4,                null: false
    t.string   "phone_number",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address",  limit: 255, default: "", null: false
    t.string   "label",          limit: 255,              null: false
  end

  create_table "api_keys", force: true do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "key",        limit: 255, null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "basket_items", force: true do |t|
    t.integer  "basket_id",            limit: 4,                                              null: false
    t.integer  "product_id",           limit: 4,                                              null: false
    t.decimal  "quantity",                           precision: 10, scale: 3, default: 1.0,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions", limit: 65535
    t.boolean  "immutable_quantity",   limit: 1,                              default: false, null: false
  end

  create_table "baskets", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "customer_note", limit: 65535
    t.string   "token",         limit: 255,   null: false
  end

  add_index "baskets", ["token"], name: "index_baskets_on_token", unique: true, using: :btree

  create_table "carousel_slides", force: true do |t|
    t.integer  "position",     limit: 4,   null: false
    t.integer  "image_id",     limit: 4,   null: false
    t.string   "caption",      limit: 255, null: false
    t.string   "link",         limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "active_from",              null: false
    t.datetime "active_until",             null: false
  end

  create_table "choices", force: true do |t|
    t.integer  "feature_id", limit: 4,   default: 0, null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["feature_id"], name: "index_choices_on_feature_id", using: :btree

  create_table "components", force: true do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "product_id", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components", ["product_id"], name: "index_components_on_product_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name",               limit: 255, default: "", null: false
    t.string   "iso_3166_1_alpha_2", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_zone_id",   limit: 4
  end

  create_table "custom_views", force: true do |t|
    t.integer  "website_id", limit: 4,     null: false
    t.string   "path",       limit: 255
    t.string   "locale",     limit: 255
    t.string   "format",     limit: 255
    t.string   "handler",    limit: 255
    t.boolean  "partial",    limit: 1
    t.text     "template",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_views", ["website_id", "path"], name: "index_custom_views_on_website_id_and_path", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "discounts", force: true do |t|
    t.string   "name",                     limit: 255,                          default: "",   null: false
    t.string   "coupon",                   limit: 255,                          default: "",   null: false
    t.string   "reward_type",              limit: 255,                          default: "",   null: false
    t.integer  "product_group_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "reward_amount",                        precision: 10, scale: 3, default: 0.0,  null: false
    t.boolean  "exclude_reduced_products", limit: 1,                            default: true, null: false
    t.decimal  "threshold",                            precision: 10, scale: 3, default: 0.0,  null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
  end

  create_table "enquiries", force: true do |t|
    t.string   "name",         limit: 255,   default: "", null: false
    t.string   "organisation", limit: 255,   default: "", null: false
    t.text     "address",      limit: 65535
    t.string   "country",      limit: 255,   default: "", null: false
    t.string   "postcode",     limit: 255,   default: "", null: false
    t.string   "telephone",    limit: 255,   default: "", null: false
    t.string   "email",        limit: 255,   default: "", null: false
    t.string   "fax",          limit: 255,   default: "", null: false
    t.text     "enquiry",      limit: 65535
    t.string   "call_back",    limit: 255,   default: "", null: false
    t.string   "hear_about",   limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",   limit: 4,     default: 0,  null: false
  end

  add_index "enquiries", ["website_id"], name: "index_enquiries_on_website_id", using: :btree

  create_table "feature_selections", force: true do |t|
    t.integer  "basket_item_id", limit: 4,     default: 0,     null: false
    t.integer  "feature_id",     limit: 4,     default: 0,     null: false
    t.integer  "choice_id",      limit: 4
    t.text     "customer_text",  limit: 65535
    t.boolean  "checked",        limit: 1,     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_selections", ["basket_item_id"], name: "index_feature_selections_on_basket_item_id", using: :btree

  create_table "features", force: true do |t|
    t.integer  "product_id",   limit: 4
    t.string   "name",         limit: 255, default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ui_type",      limit: 4,   default: 0,    null: false
    t.boolean  "required",     limit: 1,   default: true, null: false
    t.integer  "component_id", limit: 4
  end

  add_index "features", ["component_id"], name: "index_features_on_component_id", using: :btree
  add_index "features", ["product_id"], name: "index_features_on_product_id", using: :btree

  create_table "forums", force: true do |t|
    t.string  "name",       limit: 255, default: "",    null: false
    t.integer "website_id", limit: 4,   default: 0,     null: false
    t.boolean "locked",     limit: 1,   default: false, null: false
  end

  add_index "forums", ["website_id"], name: "index_forums_on_website_id", using: :btree

  create_table "images", force: true do |t|
    t.integer  "website_id", limit: 4,   default: 0,  null: false
    t.string   "name",       limit: 255, default: "", null: false
    t.string   "filename",   limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liquid_templates", force: true do |t|
    t.string   "name",       limit: 255,                null: false
    t.text     "markup",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255,   default: "", null: false
  end

  add_index "liquid_templates", ["name"], name: "index_liquid_templates_on_name", using: :btree

  create_table "nominal_codes", force: true do |t|
    t.integer  "website_id",  limit: 4,   null: false
    t.string   "code",        limit: 255, null: false
    t.string   "description", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "nominal_codes", ["code"], name: "index_nominal_codes_on_code", using: :btree
  add_index "nominal_codes", ["website_id"], name: "index_nominal_codes_on_website_id", using: :btree

  create_table "order_lines", force: true do |t|
    t.integer  "order_id",             limit: 4,                              default: 0,   null: false
    t.integer  "product_id",           limit: 4,                              default: 0,   null: false
    t.string   "product_sku",          limit: 255,                            default: "",  null: false
    t.string   "product_name",         limit: 255,                            default: "",  null: false
    t.decimal  "product_price",                      precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "tax_amount",                         precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "quantity",                           precision: 10, scale: 3, default: 1.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions", limit: 65535
    t.integer  "shipped",              limit: 4,                              default: 0,   null: false
    t.decimal  "product_weight",                     precision: 10, scale: 3, default: 0.0, null: false
  end

  add_index "order_lines", ["order_id"], name: "index_order_lines_on_order_id", using: :btree
  add_index "order_lines", ["product_id"], name: "index_order_lines_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "user_id",                        limit: 4
    t.string   "order_number",                   limit: 255,                            default: "",  null: false
    t.string   "email_address",                  limit: 255,                            default: "",  null: false
    t.string   "delivery_full_name",             limit: 255,                            default: "",  null: false
    t.string   "delivery_address_line_1",        limit: 255,                            default: "",  null: false
    t.string   "delivery_address_line_2",        limit: 255
    t.string   "delivery_town_city",             limit: 255,                            default: "",  null: false
    t.string   "delivery_county",                limit: 255
    t.string   "delivery_postcode",              limit: 255,                            default: "",  null: false
    t.integer  "delivery_country_id",            limit: 4,                                            null: false
    t.string   "delivery_phone_number",          limit: 255
    t.decimal  "shipping_amount",                              precision: 10, scale: 3, default: 0.0, null: false
    t.string   "shipping_method",                limit: 255,                            default: "",  null: false
    t.integer  "status",                         limit: 4,                              default: 0,   null: false
    t.decimal  "total",                                        precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "basket_id",                      limit: 4
    t.date     "preferred_delivery_date"
    t.string   "preferred_delivery_date_prompt", limit: 255
    t.string   "preferred_delivery_date_format", limit: 255
    t.string   "ip_address",                     limit: 255
    t.decimal  "shipping_tax_amount",                          precision: 10, scale: 3, default: 0.0, null: false
    t.text     "customer_note",                  limit: 65535
    t.datetime "processed_at"
    t.string   "billing_full_name",              limit: 255,                            default: "",  null: false
    t.string   "billing_address_line_1",         limit: 255,                            default: "",  null: false
    t.string   "billing_address_line_2",         limit: 255
    t.string   "billing_town_city",              limit: 255,                            default: "",  null: false
    t.string   "billing_county",                 limit: 255
    t.string   "billing_postcode",               limit: 255,                            default: "",  null: false
    t.integer  "billing_country_id",             limit: 4,                                            null: false
    t.string   "billing_phone_number",           limit: 255
  end

  add_index "orders", ["basket_id"], name: "index_orders_on_basket_id", using: :btree
  add_index "orders", ["created_at"], name: "index_orders_on_created_at", using: :btree
  add_index "orders", ["email_address"], name: "index_orders_on_email_address", using: :btree
  add_index "orders", ["processed_at"], name: "index_orders_on_processed_at", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title",              limit: 255,        default: "",    null: false
    t.string   "slug",               limit: 255,        default: "",    null: false
    t.integer  "website_id",         limit: 4,                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",               limit: 255,        default: "",    null: false
    t.string   "description",        limit: 255,        default: "",    null: false
    t.text     "content",            limit: 4294967295
    t.integer  "parent_id",          limit: 4
    t.integer  "position",           limit: 4,          default: 0
    t.integer  "image_id",           limit: 4
    t.boolean  "no_follow",          limit: 1,          default: false, null: false
    t.boolean  "no_index",           limit: 1,          default: false, null: false
    t.text     "extra",              limit: 4294967295
    t.integer  "thumbnail_image_id", limit: 4
  end

  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree
  add_index "pages", ["thumbnail_image_id"], name: "index_pages_on_thumbnail_image_id", using: :btree
  add_index "pages", ["website_id"], name: "index_pages_on_website_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "order_id",           limit: 4
    t.string   "service_provider",   limit: 255
    t.string   "installation_id",    limit: 255
    t.string   "cart_id",            limit: 255
    t.string   "description",        limit: 255
    t.string   "amount",             limit: 255
    t.string   "currency",           limit: 255
    t.boolean  "test_mode",          limit: 1
    t.string   "name",               limit: 255
    t.string   "address",            limit: 255
    t.string   "postcode",           limit: 255
    t.string   "country",            limit: 255
    t.string   "telephone",          limit: 255
    t.string   "fax",                limit: 255
    t.string   "email",              limit: 255
    t.string   "transaction_id",     limit: 255
    t.string   "transaction_status", limit: 255
    t.string   "transaction_time",   limit: 255
    t.text     "raw_auth_message",   limit: 65535
    t.boolean  "accepted",           limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permutations", force: true do |t|
    t.integer  "component_id",    limit: 4,                                          null: false
    t.string   "permutation",     limit: 255,                                        null: false
    t.boolean  "valid_selection", limit: 1,                                          null: false
    t.decimal  "price",                       precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "weight",                      precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permutations", ["component_id"], name: "index_permutations_on_component_id", using: :btree
  add_index "permutations", ["permutation"], name: "index_permutations_on_permutation", using: :btree

  create_table "posts", force: true do |t|
    t.integer  "topic_id",   limit: 4,     default: 0,  null: false
    t.text     "content",    limit: 65535
    t.string   "author",     limit: 255,   default: "", null: false
    t.string   "email",      limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["topic_id"], name: "index_posts_on_topic_id", using: :btree

  create_table "preferred_delivery_date_settings", force: true do |t|
    t.integer  "website_id",                     limit: 4,   default: 0,                         null: false
    t.string   "prompt",                         limit: 255, default: "Preferred delivery date", null: false
    t.string   "date_format",                    limit: 255, default: "%a %d %b"
    t.integer  "number_of_dates_to_show",        limit: 4,   default: 5,                         null: false
    t.string   "rfc2822_week_commencing_day",    limit: 255
    t.integer  "number_of_initial_days_to_skip", limit: 4,   default: 1,                         null: false
    t.string   "skip_after_time_of_day",         limit: 255
    t.boolean  "skip_bank_holidays",             limit: 1,   default: true,                      null: false
    t.boolean  "skip_saturdays",                 limit: 1,   default: true,                      null: false
    t.boolean  "skip_sundays",                   limit: 1,   default: true,                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferred_delivery_date_settings", ["website_id"], name: "index_preferred_delivery_date_settings_on_website_id", using: :btree

  create_table "product_group_placements", force: true do |t|
    t.integer  "product_id",       limit: 4, default: 0, null: false
    t.integer  "product_group_id", limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_groups", force: true do |t|
    t.integer  "website_id", limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_placements", force: true do |t|
    t.integer  "page_id",    limit: 4, default: 0, null: false
    t.integer  "product_id", limit: 4, default: 0, null: false
    t.integer  "position",   limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_placements", ["page_id"], name: "index_product_placements_on_page_id", using: :btree
  add_index "product_placements", ["product_id"], name: "index_product_placements_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "sku",                       limit: 255,                            default: "",         null: false
    t.string   "name",                      limit: 255,                            default: "",         null: false
    t.decimal  "price",                                   precision: 10, scale: 3, default: 0.0,        null: false
    t.integer  "image_id",                  limit: 4
    t.text     "description",               limit: 65535
    t.boolean  "in_stock",                  limit: 1,                              default: true,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_shipping",            limit: 1,                              default: true,       null: false
    t.text     "full_detail",               limit: 65535
    t.integer  "tax_type",                  limit: 4,                              default: 1,          null: false
    t.decimal  "shipping_supplement",                     precision: 10, scale: 3, default: 0.0,        null: false
    t.string   "page_title",                limit: 255,                            default: "",         null: false
    t.string   "meta_description",          limit: 255,                            default: "",         null: false
    t.decimal  "weight",                                  precision: 10, scale: 3, default: 0.0,        null: false
    t.string   "google_title",              limit: 255,                            default: "",         null: false
    t.string   "condition",                 limit: 255,                            default: "new",      null: false
    t.string   "google_product_category",   limit: 255,                            default: "",         null: false
    t.string   "product_type",              limit: 255,                            default: "",         null: false
    t.string   "brand",                     limit: 255,                            default: "",         null: false
    t.string   "availability",              limit: 255,                            default: "in stock", null: false
    t.string   "gtin",                      limit: 255,                            default: "",         null: false
    t.string   "mpn",                       limit: 255,                            default: "",         null: false
    t.boolean  "submit_to_google",          limit: 1,                              default: true,       null: false
    t.decimal  "rrp",                                     precision: 10, scale: 3
    t.boolean  "active",                    limit: 1,                              default: true,       null: false
    t.string   "gender",                    limit: 255,                            default: "",         null: false
    t.string   "age_group",                 limit: 255,                            default: "",         null: false
    t.integer  "nominal_code_id",           limit: 4
    t.text     "google_description",        limit: 65535
    t.boolean  "allow_fractional_quantity", limit: 1,                              default: false,      null: false
  end

  add_index "products", ["nominal_code_id"], name: "index_products_on_nominal_code_id", using: :btree

  create_table "quantity_prices", force: true do |t|
    t.integer  "product_id", limit: 4
    t.integer  "quantity",   limit: 4,                          default: 0,   null: false
    t.decimal  "price",                precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quantity_prices", ["product_id"], name: "index_quantity_prices_on_product_id", using: :btree

  create_table "shipping_classes", force: true do |t|
    t.integer  "shipping_zone_id",  limit: 4,   default: 0,              null: false
    t.string   "name",              limit: 255, default: "",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "table_rate_method", limit: 255, default: "basket_total", null: false
  end

  add_index "shipping_classes", ["shipping_zone_id"], name: "index_shipping_classes_on_shipping_zone_id", using: :btree

  create_table "shipping_table_rows", force: true do |t|
    t.integer  "shipping_class_id", limit: 4,                          default: 0,   null: false
    t.decimal  "trigger_value",               precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "amount",                      precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_table_rows", ["shipping_class_id"], name: "index_shipping_table_rows_on_shipping_class_id", using: :btree

  create_table "shipping_zones", force: true do |t|
    t.integer  "website_id", limit: 4,   default: 0,  null: false
    t.string   "name",       limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", force: true do |t|
    t.string   "topic",            limit: 255, default: "", null: false
    t.integer  "forum_id",         limit: 4,   default: 0,  null: false
    t.integer  "posts_count",      limit: 4,   default: 0,  null: false
    t.integer  "views",            limit: 4,   default: 0,  null: false
    t.integer  "last_post_id",     limit: 4,   default: 0,  null: false
    t.string   "last_post_author", limit: 255, default: "", null: false
    t.datetime "last_post_at",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["forum_id"], name: "index_topics_on_forum_id", using: :btree
  add_index "topics", ["last_post_at"], name: "index_topics_on_last_post_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                 limit: 255, default: "",    null: false
    t.string   "name",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",    limit: 255
    t.string   "salt",                  limit: 255
    t.string   "forgot_password_token", limit: 255, default: "",    null: false
    t.boolean  "admin",                 limit: 1,   default: false, null: false
    t.integer  "manages_website_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",            limit: 4,   default: 0,     null: false
    t.string   "customer_reference",    limit: 255, default: "",    null: false
  end

  add_index "users", ["website_id"], name: "index_users_on_website_id", using: :btree

  create_table "webhooks", force: true do |t|
    t.integer  "website_id", limit: 4,   null: false
    t.string   "event",      limit: 255, null: false
    t.string   "url",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "webhooks", ["website_id", "event"], name: "index_webhooks_on_website_id_and_event", using: :btree

  create_table "websites", force: true do |t|
    t.string   "subdomain",                          limit: 255,                            default: "",     null: false
    t.string   "domain",                             limit: 255,                            default: "",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_analytics_code",              limit: 255,                            default: "",     null: false
    t.string   "name",                               limit: 255,                            default: "",     null: false
    t.string   "email",                              limit: 255,                            default: "",     null: false
    t.text     "css_url",                            limit: 65535
    t.boolean  "use_default_css",                    limit: 1,                              default: false,  null: false
    t.boolean  "worldpay_active",                    limit: 1,                              default: false,  null: false
    t.string   "worldpay_installation_id",           limit: 255,                            default: "",     null: false
    t.string   "worldpay_payment_response_password", limit: 255,                            default: "",     null: false
    t.boolean  "worldpay_test_mode",                 limit: 1,                              default: false,  null: false
    t.boolean  "can_users_create_accounts",          limit: 1,                              default: true,   null: false
    t.boolean  "skip_payment",                       limit: 1,                              default: false,  null: false
    t.integer  "blog_id",                            limit: 4
    t.decimal  "shipping_amount",                                  precision: 10, scale: 3, default: 0.0,    null: false
    t.boolean  "private",                            limit: 1,                              default: false,  null: false
    t.boolean  "accept_payment_on_account",          limit: 1,                              default: false,  null: false
    t.string   "vat_number",                         limit: 255,                            default: "",     null: false
    t.boolean  "show_vat_inclusive_prices",          limit: 1,                              default: false,  null: false
    t.text     "terms_and_conditions",               limit: 65535
    t.string   "default_locale",                     limit: 255,                            default: "en",   null: false
    t.integer  "page_image_size",                    limit: 4,                              default: 400
    t.integer  "page_thumbnail_size",                limit: 4,                              default: 200
    t.integer  "product_image_size",                 limit: 4,                              default: 400
    t.integer  "product_thumbnail_size",             limit: 4,                              default: 200
    t.boolean  "render_blog_before_content",         limit: 1,                              default: true,   null: false
    t.string   "google_ftp_username",                limit: 255,                            default: "",     null: false
    t.string   "google_ftp_password",                limit: 255,                            default: "",     null: false
    t.text     "invoice_details",                    limit: 65535
    t.string   "google_domain_name",                 limit: 255,                            default: "",     null: false
    t.boolean  "paypal_active",                      limit: 1,                              default: false,  null: false
    t.string   "paypal_email_address",               limit: 255,                            default: "",     null: false
    t.string   "paypal_identity_token",              limit: 255,                            default: "",     null: false
    t.boolean  "cardsave_active",                    limit: 1,                              default: false,  null: false
    t.string   "cardsave_merchant_id",               limit: 255,                            default: "",     null: false
    t.string   "cardsave_password",                  limit: 255,                            default: "",     null: false
    t.string   "cardsave_pre_shared_key",            limit: 255,                            default: "",     null: false
    t.string   "address_line_1",                     limit: 255,                            default: "",     null: false
    t.string   "address_line_2",                     limit: 255,                            default: "",     null: false
    t.string   "town_city",                          limit: 255,                            default: "",     null: false
    t.string   "county",                             limit: 255,                            default: "",     null: false
    t.string   "postcode",                           limit: 255,                            default: "",     null: false
    t.integer  "country_id",                         limit: 4,                                               null: false
    t.string   "phone_number",                       limit: 255,                            default: "",     null: false
    t.string   "fax_number",                         limit: 255,                            default: "",     null: false
    t.string   "twitter_username",                   limit: 255,                            default: "",     null: false
    t.string   "skype_name",                         limit: 255,                            default: "",     null: false
    t.boolean  "sage_pay_active",                    limit: 1,                              default: false,  null: false
    t.string   "sage_pay_vendor",                    limit: 255,                            default: "",     null: false
    t.string   "sage_pay_pre_shared_key",            limit: 255,                            default: "",     null: false
    t.boolean  "sage_pay_test_mode",                 limit: 1,                              default: false,  null: false
    t.integer  "custom_view_cache_count",            limit: 4,                              default: 0,      null: false
    t.string   "custom_view_resolver",               limit: 255
    t.string   "scheme",                             limit: 255,                            default: "http", null: false
    t.integer  "port",                               limit: 4,                              default: 80,     null: false
    t.boolean  "upg_atlas_active",                   limit: 1,                              default: false,  null: false
    t.string   "upg_atlas_sh_reference",             limit: 255,                            default: "",     null: false
    t.string   "upg_atlas_check_code",               limit: 255,                            default: "",     null: false
    t.string   "upg_atlas_filename",                 limit: 255,                            default: "",     null: false
    t.boolean  "smtp_active",                        limit: 1,                              default: false,  null: false
    t.string   "smtp_host",                          limit: 255,                            default: "",     null: false
    t.string   "smtp_username",                      limit: 255,                            default: "",     null: false
    t.string   "smtp_password",                      limit: 255,                            default: "",     null: false
    t.integer  "smtp_port",                          limit: 4,                              default: 25,     null: false
    t.string   "mandrill_subaccount",                limit: 255,                            default: "",     null: false
    t.string   "theme",                              limit: 255
  end

end
