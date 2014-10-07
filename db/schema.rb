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

ActiveRecord::Schema.define(version: 20141007130123) do

  create_table "additional_products", force: true do |t|
    t.integer  "product_id",                            null: false
    t.integer  "additional_product_id",                 null: false
    t.boolean  "selected_by_default",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_products", ["product_id"], name: "index_additional_products_on_product_id", using: :btree

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.string   "full_name",      default: "", null: false
    t.string   "address_line_1", default: "", null: false
    t.string   "address_line_2", default: "", null: false
    t.string   "town_city",      default: "", null: false
    t.string   "county",         default: "", null: false
    t.string   "postcode",       default: "", null: false
    t.integer  "country_id",                  null: false
    t.string   "phone_number",   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address",  default: "", null: false
    t.string   "label",                       null: false
  end

  create_table "api_keys", force: true do |t|
    t.string   "name",       null: false
    t.string   "key",        null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "basket_items", force: true do |t|
    t.integer  "basket_id",            default: 0, null: false
    t.integer  "product_id",           default: 0, null: false
    t.integer  "quantity",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions"
  end

  create_table "baskets", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "customer_note"
    t.string   "token",         null: false
  end

  add_index "baskets", ["token"], name: "index_baskets_on_token", unique: true, using: :btree

  create_table "carousel_slides", force: true do |t|
    t.integer  "website_id",   null: false
    t.integer  "position",     null: false
    t.integer  "image_id",     null: false
    t.string   "caption",      null: false
    t.string   "link",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "active_from",  null: false
    t.datetime "active_until", null: false
  end

  create_table "choices", force: true do |t|
    t.integer  "feature_id", default: 0, null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["feature_id"], name: "index_choices_on_feature_id", using: :btree

  create_table "components", force: true do |t|
    t.string   "name",       null: false
    t.integer  "product_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components", ["product_id"], name: "index_components_on_product_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name",               default: "", null: false
    t.string   "iso_3166_1_alpha_2", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",         default: 0,  null: false
    t.integer  "shipping_zone_id"
  end

  add_index "countries", ["website_id"], name: "index_countries_on_website_id", using: :btree

  create_table "custom_views", force: true do |t|
    t.integer  "website_id", null: false
    t.string   "path"
    t.string   "locale"
    t.string   "format"
    t.string   "handler"
    t.boolean  "partial"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_views", ["website_id", "path"], name: "index_custom_views_on_website_id_and_path", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "discounts", force: true do |t|
    t.integer  "website_id",                                                       null: false
    t.string   "name",                                              default: "",   null: false
    t.string   "coupon",                                            default: "",   null: false
    t.string   "reward_type",                                       default: "",   null: false
    t.integer  "product_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "reward_amount",            precision: 10, scale: 3, default: 0.0,  null: false
    t.boolean  "exclude_reduced_products",                          default: true, null: false
    t.decimal  "threshold",                precision: 10, scale: 3, default: 0.0,  null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
  end

  create_table "enquiries", force: true do |t|
    t.string   "name",         default: "", null: false
    t.string   "organisation", default: "", null: false
    t.text     "address"
    t.string   "country",      default: "", null: false
    t.string   "postcode",     default: "", null: false
    t.string   "telephone",    default: "", null: false
    t.string   "email",        default: "", null: false
    t.string   "fax",          default: "", null: false
    t.text     "enquiry"
    t.string   "call_back",    default: "", null: false
    t.string   "hear_about",   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",   default: 0,  null: false
  end

  add_index "enquiries", ["website_id"], name: "index_enquiries_on_website_id", using: :btree

  create_table "feature_selections", force: true do |t|
    t.integer  "basket_item_id", default: 0,     null: false
    t.integer  "feature_id",     default: 0,     null: false
    t.integer  "choice_id"
    t.text     "customer_text"
    t.boolean  "checked",        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_selections", ["basket_item_id"], name: "index_feature_selections_on_basket_item_id", using: :btree

  create_table "features", force: true do |t|
    t.integer  "product_id"
    t.string   "name",         default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ui_type",      default: 0,    null: false
    t.boolean  "required",     default: true, null: false
    t.integer  "component_id"
  end

  add_index "features", ["component_id"], name: "index_features_on_component_id", using: :btree
  add_index "features", ["product_id"], name: "index_features_on_product_id", using: :btree

  create_table "forums", force: true do |t|
    t.string  "name",       default: "",    null: false
    t.integer "website_id", default: 0,     null: false
    t.boolean "locked",     default: false, null: false
  end

  add_index "forums", ["website_id"], name: "index_forums_on_website_id", using: :btree

  create_table "images", force: true do |t|
    t.integer  "website_id", default: 0,  null: false
    t.string   "name",       default: "", null: false
    t.string   "filename",   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liquid_templates", force: true do |t|
    t.integer  "website_id",              null: false
    t.string   "name",                    null: false
    t.text     "markup"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      default: "", null: false
  end

  add_index "liquid_templates", ["name"], name: "index_liquid_templates_on_name", using: :btree
  add_index "liquid_templates", ["website_id"], name: "index_liquid_templates_on_website_id", using: :btree

  create_table "order_lines", force: true do |t|
    t.integer  "order_id",                                      default: 0,   null: false
    t.integer  "product_id",                                    default: 0,   null: false
    t.string   "product_sku",                                   default: "",  null: false
    t.string   "product_name",                                  default: "",  null: false
    t.decimal  "product_price",        precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "tax_amount",           precision: 10, scale: 3, default: 0.0, null: false
    t.integer  "quantity",                                      default: 0,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions"
    t.integer  "shipped",                                       default: 0,   null: false
    t.decimal  "product_weight",       precision: 10, scale: 3, default: 0.0, null: false
  end

  add_index "order_lines", ["order_id"], name: "index_order_lines_on_order_id", using: :btree
  add_index "order_lines", ["product_id"], name: "index_order_lines_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.string   "order_number",                                            default: "",  null: false
    t.string   "email_address",                                           default: "",  null: false
    t.string   "delivery_full_name",                                      default: "",  null: false
    t.string   "delivery_address_line_1",                                 default: "",  null: false
    t.string   "delivery_address_line_2",                                 default: "",  null: false
    t.string   "delivery_town_city",                                      default: "",  null: false
    t.string   "delivery_county",                                         default: "",  null: false
    t.string   "delivery_postcode",                                       default: "",  null: false
    t.integer  "delivery_country_id",                                                   null: false
    t.string   "delivery_phone_number",                                   default: "",  null: false
    t.decimal  "shipping_amount",                precision: 10, scale: 3, default: 0.0, null: false
    t.string   "shipping_method",                                         default: "",  null: false
    t.integer  "status",                                                  default: 0,   null: false
    t.decimal  "total",                          precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",                                              default: 0,   null: false
    t.integer  "basket_id"
    t.date     "preferred_delivery_date"
    t.string   "preferred_delivery_date_prompt"
    t.string   "preferred_delivery_date_format"
    t.string   "ip_address"
    t.decimal  "shipping_tax_amount",            precision: 10, scale: 3, default: 0.0, null: false
    t.text     "customer_note"
  end

  add_index "orders", ["basket_id"], name: "index_orders_on_basket_id", using: :btree
  add_index "orders", ["created_at"], name: "index_orders_on_created_at", using: :btree
  add_index "orders", ["email_address"], name: "index_orders_on_email_address", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["website_id"], name: "index_orders_on_website_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title",                                 default: "",    null: false
    t.string   "slug",                                  default: "",    null: false
    t.integer  "website_id",                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                  default: "",    null: false
    t.string   "description",                           default: "",    null: false
    t.text     "content",            limit: 2147483647
    t.integer  "parent_id"
    t.integer  "position",                              default: 0
    t.integer  "image_id"
    t.boolean  "no_follow",                             default: false, null: false
    t.boolean  "no_index",                              default: false, null: false
    t.text     "extra",              limit: 2147483647
    t.integer  "thumbnail_image_id"
  end

  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree
  add_index "pages", ["thumbnail_image_id"], name: "index_pages_on_thumbnail_image_id", using: :btree
  add_index "pages", ["website_id"], name: "index_pages_on_website_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "order_id"
    t.string   "service_provider"
    t.string   "installation_id"
    t.string   "cart_id"
    t.string   "description"
    t.string   "amount"
    t.string   "currency"
    t.boolean  "test_mode"
    t.string   "name"
    t.string   "address"
    t.string   "postcode"
    t.string   "country"
    t.string   "telephone"
    t.string   "fax"
    t.string   "email"
    t.string   "transaction_id"
    t.string   "transaction_status"
    t.string   "transaction_time"
    t.text     "raw_auth_message"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permutations", force: true do |t|
    t.integer  "component_id",                                           null: false
    t.string   "permutation",                                            null: false
    t.boolean  "valid_selection",                                        null: false
    t.decimal  "price",           precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "weight",          precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permutations", ["component_id"], name: "index_permutations_on_component_id", using: :btree
  add_index "permutations", ["permutation"], name: "index_permutations_on_permutation", using: :btree

  create_table "posts", force: true do |t|
    t.integer  "topic_id",   default: 0,  null: false
    t.text     "content"
    t.string   "author",     default: "", null: false
    t.string   "email",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["topic_id"], name: "index_posts_on_topic_id", using: :btree

  create_table "preferred_delivery_date_settings", force: true do |t|
    t.integer  "website_id",                     default: 0,                         null: false
    t.string   "prompt",                         default: "Preferred delivery date", null: false
    t.string   "date_format",                    default: "%a %d %b"
    t.integer  "number_of_dates_to_show",        default: 5,                         null: false
    t.string   "rfc2822_week_commencing_day"
    t.integer  "number_of_initial_days_to_skip", default: 1,                         null: false
    t.string   "skip_after_time_of_day"
    t.boolean  "skip_bank_holidays",             default: true,                      null: false
    t.boolean  "skip_saturdays",                 default: true,                      null: false
    t.boolean  "skip_sundays",                   default: true,                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferred_delivery_date_settings", ["website_id"], name: "index_preferred_delivery_date_settings_on_website_id", using: :btree

  create_table "product_group_placements", force: true do |t|
    t.integer  "product_id",       default: 0, null: false
    t.integer  "product_group_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_groups", force: true do |t|
    t.integer  "website_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_placements", force: true do |t|
    t.integer  "page_id",    default: 0, null: false
    t.integer  "product_id", default: 0, null: false
    t.integer  "position",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_placements", ["page_id"], name: "index_product_placements_on_page_id", using: :btree
  add_index "product_placements", ["product_id"], name: "index_product_placements_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "website_id"
    t.string   "sku",                                              default: "",         null: false
    t.string   "name",                                             default: "",         null: false
    t.decimal  "price",                   precision: 10, scale: 3, default: 0.0,        null: false
    t.integer  "image_id"
    t.text     "description"
    t.boolean  "in_stock",                                         default: true,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_shipping",                                   default: true,       null: false
    t.text     "full_detail"
    t.integer  "tax_type",                                         default: 1,          null: false
    t.decimal  "shipping_supplement",     precision: 10, scale: 3, default: 0.0,        null: false
    t.string   "page_title",                                       default: "",         null: false
    t.string   "meta_description",                                 default: "",         null: false
    t.decimal  "weight",                  precision: 10, scale: 3, default: 0.0,        null: false
    t.string   "google_title",                                     default: "",         null: false
    t.string   "condition",                                        default: "new",      null: false
    t.string   "google_product_category",                          default: "",         null: false
    t.string   "product_type",                                     default: "",         null: false
    t.string   "brand",                                            default: "",         null: false
    t.string   "availability",                                     default: "in stock", null: false
    t.string   "gtin",                                             default: "",         null: false
    t.string   "mpn",                                              default: "",         null: false
    t.boolean  "submit_to_google",                                 default: true,       null: false
    t.decimal  "rrp",                     precision: 10, scale: 3
    t.boolean  "active",                                           default: true,       null: false
    t.string   "gender",                                           default: "",         null: false
    t.string   "age_group",                                        default: "",         null: false
  end

  add_index "products", ["website_id"], name: "index_products_on_website_id", using: :btree

  create_table "quantity_prices", force: true do |t|
    t.integer  "product_id"
    t.integer  "quantity",                            default: 0,   null: false
    t.decimal  "price",      precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quantity_prices", ["product_id"], name: "index_quantity_prices_on_product_id", using: :btree

  create_table "shipping_classes", force: true do |t|
    t.integer  "shipping_zone_id",  default: 0,              null: false
    t.string   "name",              default: "",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "table_rate_method", default: "basket_total", null: false
  end

  add_index "shipping_classes", ["shipping_zone_id"], name: "index_shipping_classes_on_shipping_zone_id", using: :btree

  create_table "shipping_table_rows", force: true do |t|
    t.integer  "shipping_class_id",                          default: 0,   null: false
    t.decimal  "trigger_value",     precision: 10, scale: 3, default: 0.0, null: false
    t.decimal  "amount",            precision: 10, scale: 3, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_table_rows", ["shipping_class_id"], name: "index_shipping_table_rows_on_shipping_class_id", using: :btree

  create_table "shipping_zones", force: true do |t|
    t.integer  "website_id", default: 0,  null: false
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", force: true do |t|
    t.string   "topic",            default: "", null: false
    t.integer  "forum_id",         default: 0,  null: false
    t.integer  "posts_count",      default: 0,  null: false
    t.integer  "views",            default: 0,  null: false
    t.integer  "last_post_id",     default: 0,  null: false
    t.string   "last_post_author", default: "", null: false
    t.datetime "last_post_at",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["forum_id"], name: "index_topics_on_forum_id", using: :btree
  add_index "topics", ["last_post_at"], name: "index_topics_on_last_post_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                 default: "",    null: false
    t.string   "name",                  default: "",    null: false
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "forgot_password_token", default: "",    null: false
    t.boolean  "admin",                 default: false, null: false
    t.integer  "manages_website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",            default: 0,     null: false
    t.string   "customer_reference",    default: "",    null: false
  end

  add_index "users", ["website_id"], name: "index_users_on_website_id", using: :btree

  create_table "webhooks", force: true do |t|
    t.integer  "website_id", null: false
    t.string   "event",      null: false
    t.string   "url",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "webhooks", ["website_id", "event"], name: "index_webhooks_on_website_id_and_event", using: :btree

  create_table "websites", force: true do |t|
    t.string   "subdomain",                                                   default: "",     null: false
    t.string   "domain",                                                      default: "",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_analytics_code",                                       default: "",     null: false
    t.string   "name",                                                        default: "",     null: false
    t.string   "email",                                                       default: "",     null: false
    t.text     "css_url"
    t.boolean  "use_default_css",                                             default: false,  null: false
    t.boolean  "worldpay_active",                                             default: false,  null: false
    t.string   "worldpay_installation_id",                                    default: "",     null: false
    t.string   "worldpay_payment_response_password",                          default: "",     null: false
    t.boolean  "worldpay_test_mode",                                          default: false,  null: false
    t.boolean  "can_users_create_accounts",                                   default: true,   null: false
    t.boolean  "skip_payment",                                                default: false,  null: false
    t.integer  "blog_id"
    t.decimal  "shipping_amount",                    precision: 10, scale: 3, default: 0.0,    null: false
    t.boolean  "private",                                                     default: false,  null: false
    t.boolean  "accept_payment_on_account",                                   default: false,  null: false
    t.string   "vat_number",                                                  default: "",     null: false
    t.boolean  "show_vat_inclusive_prices",                                   default: false,  null: false
    t.text     "terms_and_conditions"
    t.string   "default_locale",                                              default: "en",   null: false
    t.integer  "page_image_size",                                             default: 400
    t.integer  "page_thumbnail_size",                                         default: 200
    t.integer  "product_image_size",                                          default: 400
    t.integer  "product_thumbnail_size",                                      default: 200
    t.boolean  "render_blog_before_content",                                  default: true,   null: false
    t.string   "google_ftp_username",                                         default: "",     null: false
    t.string   "google_ftp_password",                                         default: "",     null: false
    t.text     "invoice_details"
    t.string   "google_domain_name",                                          default: "",     null: false
    t.boolean  "paypal_active",                                               default: false,  null: false
    t.string   "paypal_email_address",                                        default: "",     null: false
    t.string   "paypal_identity_token",                                       default: "",     null: false
    t.boolean  "cardsave_active",                                             default: false,  null: false
    t.string   "cardsave_merchant_id",                                        default: "",     null: false
    t.string   "cardsave_password",                                           default: "",     null: false
    t.string   "cardsave_pre_shared_key",                                     default: "",     null: false
    t.string   "address_line_1",                                              default: "",     null: false
    t.string   "address_line_2",                                              default: "",     null: false
    t.string   "town_city",                                                   default: "",     null: false
    t.string   "county",                                                      default: "",     null: false
    t.string   "postcode",                                                    default: "",     null: false
    t.integer  "country_id",                                                                   null: false
    t.string   "phone_number",                                                default: "",     null: false
    t.string   "fax_number",                                                  default: "",     null: false
    t.string   "twitter_username",                                            default: "",     null: false
    t.string   "skype_name",                                                  default: "",     null: false
    t.boolean  "sage_pay_active",                                             default: false,  null: false
    t.string   "sage_pay_vendor",                                             default: "",     null: false
    t.string   "sage_pay_pre_shared_key",                                     default: "",     null: false
    t.boolean  "sage_pay_test_mode",                                          default: false,  null: false
    t.integer  "custom_view_cache_count",                                     default: 0,      null: false
    t.string   "custom_view_resolver"
    t.string   "scheme",                                                      default: "http", null: false
    t.integer  "port",                                                        default: 80,     null: false
    t.boolean  "upg_atlas_active",                                            default: false,  null: false
    t.string   "upg_atlas_sh_reference",                                      default: "",     null: false
    t.string   "upg_atlas_check_code",                                        default: "",     null: false
    t.string   "upg_atlas_filename",                                          default: "",     null: false
  end

end
