# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_24_212230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_products", id: :serial, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "additional_product_id", null: false
    t.boolean "selected_by_default", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "quantity", default: 1, null: false
    t.index ["product_id"], name: "index_additional_products_on_product_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "full_name", default: "", null: false
    t.string "address_line_1", default: "", null: false
    t.string "address_line_2"
    t.string "town_city", default: "", null: false
    t.string "county"
    t.string "postcode", default: "", null: false
    t.integer "country_id", null: false
    t.string "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email_address", default: "", null: false
    t.string "label", null: false
    t.string "company"
    t.string "address_line_3"
  end

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_api_keys_on_key"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "basket_items", id: :serial, force: :cascade do |t|
    t.integer "basket_id", null: false
    t.integer "product_id", null: false
    t.decimal "quantity", precision: 10, scale: 3, default: "1.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "feature_descriptions"
    t.boolean "immutable_quantity", default: false, null: false
  end

  create_table "baskets", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "customer_note"
    t.string "token", null: false
    t.text "delivery_instructions"
    t.index ["token"], name: "index_baskets_on_token", unique: true
  end

  create_table "choices", id: :serial, force: :cascade do |t|
    t.integer "feature_id", default: 0, null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["feature_id"], name: "index_choices_on_feature_id"
  end

  create_table "components", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "product_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_components_on_product_id"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "iso_3166_1_alpha_2", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "shipping_zone_id"
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "custom_views", id: :serial, force: :cascade do |t|
    t.integer "website_id", null: false
    t.string "path"
    t.string "locale"
    t.string "format"
    t.string "handler"
    t.boolean "partial"
    t.text "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["website_id", "path"], name: "index_custom_views_on_website_id_and_path"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "discounts", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "coupon", default: "", null: false
    t.string "reward_type", default: "", null: false
    t.integer "product_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "reward_amount", precision: 10, scale: 3, default: "0.0", null: false
    t.boolean "exclude_reduced_products", default: true, null: false
    t.decimal "threshold", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
  end

  create_table "enquiries", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "organisation", default: "", null: false
    t.text "address"
    t.string "country", default: "", null: false
    t.string "postcode", default: "", null: false
    t.string "telephone", default: "", null: false
    t.string "email", default: "", null: false
    t.string "fax", default: "", null: false
    t.text "enquiry"
    t.string "call_back", default: "", null: false
    t.string "hear_about", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "website_id", default: 0, null: false
    t.index ["website_id"], name: "index_enquiries_on_website_id"
  end

  create_table "extra_attributes", id: :serial, force: :cascade do |t|
    t.string "class_name"
    t.string "attribute_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_selections", id: :serial, force: :cascade do |t|
    t.integer "basket_item_id", default: 0, null: false
    t.integer "feature_id", default: 0, null: false
    t.integer "choice_id"
    t.text "customer_text"
    t.boolean "checked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["basket_item_id"], name: "index_feature_selections_on_basket_item_id"
  end

  create_table "features", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.string "name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "ui_type", default: 0, null: false
    t.boolean "required", default: true, null: false
    t.integer "component_id"
    t.index ["component_id"], name: "index_features_on_component_id"
    t.index ["product_id"], name: "index_features_on_product_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "filename", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liquid_templates", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "markup"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title", default: "", null: false
    t.index ["name"], name: "index_liquid_templates_on_name"
  end

  create_table "offline_payment_methods", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_comments", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_comments_on_order_id"
  end

  create_table "order_lines", id: :serial, force: :cascade do |t|
    t.integer "order_id", default: 0, null: false
    t.integer "product_id"
    t.string "product_sku", default: "", null: false
    t.string "product_name", default: "", null: false
    t.decimal "product_price", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "tax_amount", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "quantity", precision: 10, scale: 3, default: "1.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "feature_descriptions"
    t.integer "shipped", default: 0, null: false
    t.decimal "product_weight", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "product_rrp", precision: 10, scale: 3
    t.index ["order_id"], name: "index_order_lines_on_order_id"
    t.index ["product_id"], name: "index_order_lines_on_product_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "order_number", default: "", null: false
    t.string "email_address", default: "", null: false
    t.string "delivery_full_name", default: "", null: false
    t.string "delivery_address_line_1", default: "", null: false
    t.string "delivery_address_line_2"
    t.string "delivery_town_city", default: "", null: false
    t.string "delivery_county"
    t.string "delivery_postcode", default: "", null: false
    t.integer "delivery_country_id"
    t.string "delivery_phone_number"
    t.decimal "shipping_amount", precision: 10, scale: 3, default: "0.0", null: false
    t.string "shipping_method", default: "", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "basket_id"
    t.date "preferred_delivery_date"
    t.string "preferred_delivery_date_prompt"
    t.string "preferred_delivery_date_format"
    t.string "ip_address"
    t.decimal "shipping_tax_amount", precision: 10, scale: 3, default: "0.0", null: false
    t.text "customer_note"
    t.datetime "processed_at"
    t.string "billing_full_name", default: "", null: false
    t.string "billing_address_line_1", default: "", null: false
    t.string "billing_address_line_2"
    t.string "billing_town_city", default: "", null: false
    t.string "billing_county"
    t.string "billing_postcode", default: "", null: false
    t.integer "billing_country_id", null: false
    t.string "billing_phone_number"
    t.string "billing_company"
    t.string "delivery_company"
    t.string "billing_address_line_3"
    t.string "delivery_address_line_3"
    t.string "shipping_tracking_number"
    t.datetime "shipped_at"
    t.datetime "shipment_email_sent_at"
    t.datetime "invoice_sent_at"
    t.string "po_number"
    t.text "delivery_instructions"
    t.datetime "sales_conversion_recorded_at"
    t.boolean "requires_delivery_address", default: true, null: false
    t.index ["basket_id"], name: "index_orders_on_basket_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["email_address"], name: "index_orders_on_email_address"
    t.index ["processed_at"], name: "index_orders_on_processed_at"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.string "slug", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
    t.text "content"
    t.integer "parent_id"
    t.integer "position", default: 0
    t.integer "image_id"
    t.boolean "no_follow", default: false, null: false
    t.boolean "no_index", default: false, null: false
    t.text "extra"
    t.integer "thumbnail_image_id"
    t.boolean "visible", default: true, null: false
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["slug"], name: "index_pages_on_slug"
    t.index ["thumbnail_image_id"], name: "index_pages_on_thumbnail_image_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.string "service_provider"
    t.string "installation_id"
    t.string "cart_id"
    t.string "description"
    t.string "currency"
    t.boolean "test_mode"
    t.string "name"
    t.string "address"
    t.string "postcode"
    t.string "country"
    t.string "telephone"
    t.string "fax"
    t.string "email"
    t.string "transaction_id"
    t.string "transaction_status"
    t.string "transaction_time"
    t.text "raw_auth_message"
    t.boolean "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "amount", precision: 10, scale: 2, null: false
  end

  create_table "permutations", id: :serial, force: :cascade do |t|
    t.integer "component_id", null: false
    t.string "permutation", null: false
    t.boolean "valid_selection", null: false
    t.decimal "price", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "weight", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["component_id"], name: "index_permutations_on_component_id"
    t.index ["permutation"], name: "index_permutations_on_permutation"
  end

  create_table "preferred_delivery_date_settings", id: :serial, force: :cascade do |t|
    t.integer "website_id", default: 0, null: false
    t.string "prompt", default: "Preferred delivery date", null: false
    t.string "date_format", default: "%a %d %b"
    t.integer "number_of_dates_to_show", default: 5, null: false
    t.string "rfc2822_week_commencing_day"
    t.integer "number_of_initial_days_to_skip", default: 1, null: false
    t.string "skip_after_time_of_day"
    t.boolean "skip_bank_holidays", default: true, null: false
    t.boolean "skip_saturdays", default: true, null: false
    t.boolean "skip_sundays", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["website_id"], name: "index_preferred_delivery_date_settings_on_website_id"
  end

  create_table "product_group_placements", id: :serial, force: :cascade do |t|
    t.integer "product_id", default: 0, null: false
    t.integer "product_group_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location", default: "", null: false
  end

  create_table "product_images", id: :serial, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_product_images_on_image_id"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_placements", id: :serial, force: :cascade do |t|
    t.integer "page_id", default: 0, null: false
    t.integer "product_id", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id"], name: "index_product_placements_on_page_id"
    t.index ["product_id"], name: "index_product_placements_on_product_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "sku", default: "", null: false
    t.string "name", default: "", null: false
    t.decimal "price", precision: 10, scale: 3, default: "0.0", null: false
    t.integer "image_id"
    t.text "description"
    t.boolean "in_stock", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "apply_shipping", default: true, null: false
    t.text "full_detail"
    t.integer "tax_type", default: 1, null: false
    t.decimal "shipping_supplement", precision: 10, scale: 3, default: "0.0", null: false
    t.string "page_title", default: "", null: false
    t.string "meta_description", default: "", null: false
    t.decimal "weight", precision: 10, scale: 3, default: "0.0", null: false
    t.string "google_title", default: "", null: false
    t.string "condition", default: "new", null: false
    t.string "google_product_category", default: "", null: false
    t.string "product_type", default: "", null: false
    t.string "brand", default: "", null: false
    t.string "availability", default: "in stock", null: false
    t.string "gtin", default: "", null: false
    t.string "mpn", default: "", null: false
    t.boolean "submit_to_google", default: true, null: false
    t.decimal "rrp", precision: 10, scale: 3
    t.boolean "active", default: true, null: false
    t.string "gender", default: "", null: false
    t.string "age_group", default: "", null: false
    t.text "google_description"
    t.boolean "allow_fractional_quantity", default: false, null: false
    t.text "extra"
    t.boolean "oversize", default: false, null: false
    t.string "pricing_method", default: "basic", null: false
  end

  create_table "quantity_prices", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "quantity", default: 0, null: false
    t.decimal "price", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_quantity_prices_on_product_id"
  end

  create_table "related_product_scores", id: :serial, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "related_product_id", null: false
    t.decimal "score", precision: 4, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_related_product_scores_on_product_id"
  end

  create_table "shipments", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "courier_name"
    t.string "tracking_number"
    t.string "tracking_url"
    t.string "picked_by"
    t.integer "number_of_parcels", default: 1, null: false
    t.decimal "total_weight", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "shipped_at"
    t.boolean "partial", default: false, null: false
    t.datetime "email_sent_at"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_sent_at"], name: "index_shipments_on_email_sent_at"
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["shipped_at"], name: "index_shipments_on_shipped_at"
  end

  create_table "shipping_classes", id: :serial, force: :cascade do |t|
    t.integer "shipping_zone_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "table_rate_method", default: "basket_total", null: false
    t.boolean "charge_tax", default: true, null: false
    t.boolean "invalid_over_highest_trigger", default: false, null: false
    t.boolean "allow_oversize", default: true, null: false
    t.boolean "requires_delivery_address", default: true, null: false
    t.index ["shipping_zone_id"], name: "index_shipping_classes_on_shipping_zone_id"
  end

  create_table "shipping_table_rows", id: :serial, force: :cascade do |t|
    t.integer "shipping_class_id", default: 0, null: false
    t.decimal "trigger_value", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "amount", precision: 10, scale: 3, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["shipping_class_id"], name: "index_shipping_table_rows_on_shipping_class_id"
  end

  create_table "shipping_zones", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "default_shipping_class_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password"
    t.string "salt"
    t.string "forgot_password_token", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.integer "manages_website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "customer_reference", default: "", null: false
  end

  create_table "webhooks", id: :serial, force: :cascade do |t|
    t.integer "website_id", null: false
    t.string "event", null: false
    t.string "url", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["website_id", "event"], name: "index_webhooks_on_website_id_and_event"
  end

  create_table "websites", id: :serial, force: :cascade do |t|
    t.string "subdomain", default: "", null: false
    t.string "domain", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "google_analytics_code", default: "", null: false
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.text "css_url"
    t.boolean "use_default_css", default: false, null: false
    t.boolean "worldpay_active", default: false, null: false
    t.string "worldpay_installation_id", default: "", null: false
    t.string "worldpay_payment_response_password", default: "", null: false
    t.boolean "worldpay_test_mode", default: false, null: false
    t.boolean "can_users_create_accounts", default: true, null: false
    t.boolean "skip_payment", default: false, null: false
    t.decimal "shipping_amount", precision: 10, scale: 3, default: "0.0", null: false
    t.boolean "private", default: false, null: false
    t.boolean "accept_payment_on_account", default: false, null: false
    t.string "vat_number", default: "", null: false
    t.boolean "show_vat_inclusive_prices", default: false, null: false
    t.text "terms_and_conditions"
    t.string "default_locale", default: "en", null: false
    t.integer "page_image_size", default: 400
    t.integer "page_thumbnail_size", default: 200
    t.integer "product_image_size", default: 400
    t.integer "product_thumbnail_size", default: 200
    t.string "google_ftp_username", default: "", null: false
    t.string "google_ftp_password", default: "", null: false
    t.text "invoice_details"
    t.string "google_domain_name", default: "", null: false
    t.boolean "paypal_active", default: false, null: false
    t.string "paypal_email_address", default: "", null: false
    t.string "paypal_identity_token", default: "", null: false
    t.boolean "cardsave_active", default: false, null: false
    t.string "cardsave_merchant_id", default: "", null: false
    t.string "cardsave_password", default: "", null: false
    t.string "cardsave_pre_shared_key", default: "", null: false
    t.string "address_line_1", default: "", null: false
    t.string "address_line_2", default: "", null: false
    t.string "town_city", default: "", null: false
    t.string "county", default: "", null: false
    t.string "postcode", default: "", null: false
    t.integer "country_id", null: false
    t.string "phone_number", default: "", null: false
    t.string "fax_number", default: "", null: false
    t.string "twitter_username", default: "", null: false
    t.string "skype_name", default: "", null: false
    t.boolean "sage_pay_active", default: false, null: false
    t.string "sage_pay_vendor", default: "", null: false
    t.string "sage_pay_pre_shared_key", default: "", null: false
    t.boolean "sage_pay_test_mode", default: false, null: false
    t.integer "custom_view_cache_count", default: 0, null: false
    t.string "custom_view_resolver"
    t.string "scheme", default: "http", null: false
    t.integer "port", default: 80, null: false
    t.boolean "smtp_active", default: false, null: false
    t.string "smtp_host", default: "", null: false
    t.string "smtp_username", default: "", null: false
    t.string "smtp_password", default: "", null: false
    t.integer "smtp_port", default: 25, null: false
    t.string "mandrill_subaccount", default: "", null: false
    t.string "theme"
    t.boolean "send_pending_payment_emails", default: true, null: false
    t.string "staging_password"
    t.boolean "paypal_test_mode", default: false, null: false
    t.boolean "shopping_suspended", default: false, null: false
    t.string "shopping_suspended_message"
    t.boolean "yorkshire_payments_active", default: false, null: false
    t.string "yorkshire_payments_merchant_id", default: "", null: false
    t.string "yorkshire_payments_pre_shared_key", default: "", null: false
    t.integer "default_shipping_class_id"
  end

end
