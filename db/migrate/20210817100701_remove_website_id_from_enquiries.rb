class RemoveWebsiteIdFromEnquiries < ActiveRecord::Migration[6.1]
  def up
    create_table "additional_products", force: :cascade do |t|
      t.integer "product_id", null: false
      t.integer "additional_product_id", null: false
      t.boolean "selected_by_default", default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "quantity", default: 1, null: false
      t.index ["product_id"], name: "index_additional_products_on_product_id"
    end

    create_table "addresses", force: :cascade do |t|
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
      t.string "mobile_number"
    end

    create_table "administrators", force: :cascade do |t|
      t.string "name", null: false
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["email"], name: "index_administrators_on_email", unique: true
      t.index ["reset_password_token"], name: "index_administrators_on_reset_password_token", unique: true
    end

    create_table "api_keys", force: :cascade do |t|
      t.string "name", null: false
      t.string "key", null: false
      t.integer "user_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["key"], name: "index_api_keys_on_key"
      t.index ["user_id"], name: "index_api_keys_on_user_id"
    end

    create_table "basket_items", force: :cascade do |t|
      t.integer "basket_id", null: false
      t.integer "product_id", null: false
      t.decimal "quantity", precision: 10, scale: 3, default: "1.0", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "feature_descriptions"
      t.boolean "immutable_quantity", default: false, null: false
      t.boolean "reward", default: false, null: false
    end

    create_table "baskets", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "customer_note"
      t.string "token", null: false
      t.text "delivery_instructions"
      t.string "email", limit: 191
      t.string "mobile"
      t.string "name"
      t.string "phone"
      t.bigint "shipping_class_id"
      t.boolean "am_delivery", default: false, null: false
      t.index ["email"], name: "index_baskets_on_email"
      t.index ["shipping_class_id"], name: "index_baskets_on_shipping_class_id"
      t.index ["token"], name: "index_baskets_on_token", unique: true
    end

    create_table "choices", force: :cascade do |t|
      t.integer "feature_id", default: 0, null: false
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["feature_id"], name: "index_choices_on_feature_id"
    end

    create_table "clients", force: :cascade do |t|
      t.integer "clientable_id", null: false
      t.string "clientable_type", null: false
      t.string "ip_address", limit: 45
      t.string "platform", default: "web", null: false
      t.string "device"
      t.text "user_agent"
      t.string "operating_system"
      t.string "browser"
      t.string "browser_version"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["clientable_type", "clientable_id"], name: "index_clients_on_clientable_type_and_clientable_id"
      t.index ["ip_address"], name: "index_clients_on_ip_address"
    end

    create_table "closure_dates", force: :cascade do |t|
      t.date "closed_on", null: false
      t.boolean "delivery_possible", default: false, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "collection_ready_emails", force: :cascade do |t|
      t.bigint "order_id", null: false
      t.datetime "sent_at"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["order_id"], name: "index_collection_ready_emails_on_order_id"
    end

    create_table "components", force: :cascade do |t|
      t.string "name", null: false
      t.integer "product_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["product_id"], name: "index_components_on_product_id"
    end

    create_table "countries", force: :cascade do |t|
      t.string "name", default: "", null: false
      t.string "iso_3166_1_alpha_2", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "shipping_zone_id"
      t.boolean "in_eu", default: false, null: false
      t.index ["name"], name: "index_countries_on_name", unique: true
    end

    create_table "couriers", force: :cascade do |t|
      t.string "name", null: false
      t.string "account_number"
      t.string "tracking_url"
      t.boolean "generate_consignment_number", default: false, null: false
      t.string "consignment_prefix"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "custom_views", force: :cascade do |t|
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

    create_table "discount_uses", force: :cascade do |t|
      t.bigint "order_id", null: false
      t.bigint "discount_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["discount_id"], name: "index_discount_uses_on_discount_id"
      t.index ["order_id"], name: "index_discount_uses_on_order_id"
    end

    create_table "discounts", force: :cascade do |t|
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
      t.string "code"
      t.integer "uses_remaining"
    end

    create_table "enquiries", force: :cascade do |t|
      t.string "name", default: "", null: false
      t.string "organisation", default: "", null: false
      t.text "address"
      t.string "country", default: "", null: false
      t.string "postcode", default: "", null: false
      t.string "telephone", default: "", null: false
      t.string "email", default: "", null: false
      t.text "enquiry"
      t.string "call_back", default: "", null: false
      t.string "hear_about", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "extra_attributes", force: :cascade do |t|
      t.string "class_name"
      t.string "attribute_name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "feature_selections", force: :cascade do |t|
      t.integer "basket_item_id", default: 0, null: false
      t.integer "feature_id", default: 0, null: false
      t.integer "choice_id"
      t.text "customer_text"
      t.boolean "checked", default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["basket_item_id"], name: "index_feature_selections_on_basket_item_id"
    end

    create_table "features", force: :cascade do |t|
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

    create_table "images", force: :cascade do |t|
      t.string "name", default: "", null: false
      t.string "filename", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "md5_hash", limit: 32
      t.index ["md5_hash"], name: "index_images_on_md5_hash"
    end

    create_table "liquid_templates", force: :cascade do |t|
      t.string "name", null: false
      t.text "markup"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "title", default: "", null: false
      t.index ["name"], name: "index_liquid_templates_on_name"
    end

    create_table "location_orders_exceeded_entries", force: :cascade do |t|
      t.bigint "location_id", null: false
      t.date "exceeded_on", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["location_id"], name: "index_location_orders_exceeded_entries_on_location_id"
    end

    create_table "locations", force: :cascade do |t|
      t.string "name", null: false
      t.integer "max_daily_orders", default: 0, null: false
      t.string "label", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "offline_payment_methods", force: :cascade do |t|
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "order_comments", force: :cascade do |t|
      t.integer "order_id", null: false
      t.text "comment"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["order_id"], name: "index_order_comments_on_order_id"
    end

    create_table "order_lines", force: :cascade do |t|
      t.integer "order_id", default: 0, null: false
      t.integer "product_id"
      t.string "product_sku", default: "", null: false
      t.string "product_name", default: "", null: false
      t.decimal "product_price", precision: 10, scale: 3, default: "0.0", null: false
      t.decimal "vat_amount", precision: 10, scale: 3, default: "0.0", null: false
      t.decimal "quantity", precision: 10, scale: 3, default: "1.0", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "feature_descriptions"
      t.integer "shipped", default: 0, null: false
      t.decimal "product_weight", precision: 10, scale: 3, default: "0.0", null: false
      t.decimal "product_rrp", precision: 10, scale: 3
      t.string "product_brand", default: "", null: false
      t.index ["order_id"], name: "index_order_lines_on_order_id"
      t.index ["product_id"], name: "index_order_lines_on_product_id"
    end

    create_table "orders", force: :cascade do |t|
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
      t.string "ip_address"
      t.decimal "shipping_vat_amount", precision: 10, scale: 3, default: "0.0", null: false
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
      t.datetime "shipped_at"
      t.datetime "shipment_email_sent_at"
      t.datetime "invoice_sent_at"
      t.string "po_number"
      t.text "delivery_instructions"
      t.datetime "sales_conversion_recorded_at"
      t.boolean "requires_delivery_address", default: true, null: false
      t.string "stripe_customer_id"
      t.date "delivery_date"
      t.date "estimated_delivery_date"
      t.boolean "locked", default: false, null: false
      t.string "vat_number"
      t.datetime "confirmation_sent_at"
      t.boolean "credit_account", default: false, null: false
      t.datetime "invoiced_at"
      t.date "paid_on"
      t.date "dispatch_date"
      t.boolean "on_hold", default: false, null: false
      t.datetime "completed_at"
      t.boolean "logged_in", default: false, null: false
      t.boolean "am_delivery", default: false, null: false
      t.string "billing_mobile_number"
      t.string "delivery_mobile_number"
      t.string "email_confirmation_token", default: "", null: false
      t.string "token"
      t.index ["basket_id"], name: "index_orders_on_basket_id"
      t.index ["created_at"], name: "index_orders_on_created_at"
      t.index ["email_address"], name: "index_orders_on_email_address"
      t.index ["processed_at"], name: "index_orders_on_processed_at"
      t.index ["token"], name: "index_orders_on_token"
      t.index ["user_id"], name: "index_orders_on_user_id"
    end

    create_table "pages", force: :cascade do |t|
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
      t.bigint "canonical_page_id"
      t.string "cached_name_with_ancestors"
      t.index ["canonical_page_id"], name: "index_pages_on_canonical_page_id"
      t.index ["parent_id"], name: "index_pages_on_parent_id"
      t.index ["slug"], name: "index_pages_on_slug"
      t.index ["thumbnail_image_id"], name: "index_pages_on_thumbnail_image_id"
    end

    create_table "payments", force: :cascade do |t|
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
      t.boolean "apple_pay", default: false, null: false
      t.boolean "stored", default: false, null: false
    end

    create_table "permutations", force: :cascade do |t|
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

    create_table "product_group_placements", force: :cascade do |t|
      t.integer "product_id", default: 0, null: false
      t.integer "product_group_id", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "product_groups", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.bigint "location_id"
      t.integer "delivery_cutoff_hour", default: 0, null: false
      t.index ["location_id"], name: "index_product_groups_on_location_id"
    end

    create_table "product_images", force: :cascade do |t|
      t.integer "product_id", null: false
      t.integer "image_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["image_id"], name: "index_product_images_on_image_id"
      t.index ["product_id"], name: "index_product_images_on_product_id"
    end

    create_table "product_placements", force: :cascade do |t|
      t.integer "page_id", default: 0, null: false
      t.integer "product_id", default: 0, null: false
      t.integer "position", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["page_id"], name: "index_product_placements_on_page_id"
      t.index ["product_id"], name: "index_product_placements_on_product_id"
    end

    create_table "products", force: :cascade do |t|
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
      t.integer "lead_time", default: 1, null: false
      t.string "slug"
      t.index ["slug"], name: "index_products_on_slug"
    end

    create_table "quantity_prices", force: :cascade do |t|
      t.integer "product_id"
      t.integer "quantity", default: 0, null: false
      t.decimal "price", precision: 10, scale: 3, default: "0.0", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["product_id"], name: "index_quantity_prices_on_product_id"
    end

    create_table "related_product_scores", force: :cascade do |t|
      t.integer "product_id", null: false
      t.integer "related_product_id", null: false
      t.decimal "score", precision: 4, scale: 3, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["product_id"], name: "index_related_product_scores_on_product_id"
    end

    create_table "shipments", force: :cascade do |t|
      t.integer "order_id", null: false
      t.string "consignment_number"
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
      t.bigint "courier_id", null: false
      t.index ["courier_id"], name: "index_shipments_on_courier_id"
      t.index ["email_sent_at"], name: "index_shipments_on_email_sent_at"
      t.index ["order_id"], name: "index_shipments_on_order_id"
      t.index ["shipped_at"], name: "index_shipments_on_shipped_at"
    end

    create_table "shipping_classes", force: :cascade do |t|
      t.integer "shipping_zone_id", default: 0, null: false
      t.string "name", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "table_rate_method", default: "basket_total", null: false
      t.boolean "charge_vat", default: true, null: false
      t.boolean "invalid_over_highest_trigger", default: false, null: false
      t.boolean "allow_oversize", default: true, null: false
      t.boolean "requires_delivery_address", default: true, null: false
      t.boolean "choose_date", default: false, null: false
      t.integer "max_product_weight", default: 0, null: false
      t.text "postcode_districts"
      t.boolean "allows_am_delivery", default: false, null: false
      t.index ["shipping_zone_id"], name: "index_shipping_classes_on_shipping_zone_id"
    end

    create_table "shipping_table_rows", force: :cascade do |t|
      t.integer "shipping_class_id", default: 0, null: false
      t.decimal "trigger_value", precision: 10, scale: 3, default: "0.0", null: false
      t.decimal "amount", precision: 10, scale: 3, default: "0.0", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["shipping_class_id"], name: "index_shipping_table_rows_on_shipping_class_id"
    end

    create_table "shipping_zones", force: :cascade do |t|
      t.string "name", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "default_shipping_class_id"
    end

    create_table "slug_histories", force: :cascade do |t|
      t.bigint "page_id", null: false
      t.string "slug"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["page_id"], name: "index_slug_histories_on_page_id"
      t.index ["slug"], name: "index_slug_histories_on_slug"
    end

    create_table "users", force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "name", default: "", null: false
      t.string "encrypted_password"
      t.string "salt"
      t.string "forgot_password_token", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "customer_reference", default: "", null: false
      t.string "stripe_customer_id"
      t.string "email_verification_token"
      t.datetime "email_verified_at"
      t.datetime "forgot_password_sent_at"
      t.datetime "explicit_opt_in_at"
      t.boolean "opt_in", default: true, null: false
    end

    create_table "webhooks", force: :cascade do |t|
      t.integer "website_id", null: false
      t.string "event", null: false
      t.string "url", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["website_id", "event"], name: "index_webhooks_on_website_id_and_event"
    end

    create_table "websites", force: :cascade do |t|
      t.string "subdomain", default: "", null: false
      t.string "domain", default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "google_analytics_code", default: "", null: false
      t.string "name", default: "", null: false
      t.string "email", default: "", null: false
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
      t.string "order_notifier_email"
      t.integer "delivery_cutoff_hour", default: 10, null: false
    end

    add_foreign_key "collection_ready_emails", "orders"
    add_foreign_key "discount_uses", "discounts"
    add_foreign_key "discount_uses", "orders"
    add_foreign_key "location_orders_exceeded_entries", "locations"
    add_foreign_key "pages", "pages", column: "canonical_page_id"
    add_foreign_key "product_groups", "locations"
    add_foreign_key "shipments", "couriers"
    add_foreign_key "slug_histories", "pages"
  end
end
