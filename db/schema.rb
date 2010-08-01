# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100729172707) do

  create_table "addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "full_name",      :default => "", :null => false
    t.string   "address_line_1", :default => "", :null => false
    t.string   "address_line_2", :default => "", :null => false
    t.string   "town_city",      :default => "", :null => false
    t.string   "county",         :default => "", :null => false
    t.string   "postcode",       :default => "", :null => false
    t.integer  "country_id",     :default => 0,  :null => false
    t.string   "phone_number",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address",  :default => "", :null => false
  end

  create_table "basket_items", :force => true do |t|
    t.integer  "basket_id",            :default => 0, :null => false
    t.integer  "product_id",           :default => 0, :null => false
    t.integer  "quantity",             :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions",                :null => false
  end

  create_table "baskets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choices", :force => true do |t|
    t.integer  "feature_id", :default => 0, :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["feature_id"], :name => "index_choices_on_attribute_id"

  create_table "countries", :force => true do |t|
    t.string   "name",               :default => "", :null => false
    t.string   "iso_3166_1_alpha_2", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", :force => true do |t|
    t.integer  "website_id",             :default => 0,  :null => false
    t.string   "name",                   :default => "", :null => false
    t.string   "coupon",                 :default => "", :null => false
    t.string   "reward_type",            :default => "", :null => false
    t.integer  "free_products_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enquiries", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.string   "organisation", :default => "", :null => false
    t.text     "address",                      :null => false
    t.string   "country",      :default => "", :null => false
    t.string   "postcode",     :default => "", :null => false
    t.string   "telephone",    :default => "", :null => false
    t.string   "email",        :default => "", :null => false
    t.string   "fax",          :default => "", :null => false
    t.text     "enquiry",                      :null => false
    t.string   "call_back",    :default => "", :null => false
    t.string   "hear_about",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",   :default => 0,  :null => false
  end

  add_index "enquiries", ["website_id"], :name => "index_enquiries_on_website_id"

  create_table "feature_selections", :force => true do |t|
    t.integer  "basket_item_id", :default => 0,     :null => false
    t.integer  "feature_id",     :default => 0,     :null => false
    t.integer  "choice_id"
    t.text     "customer_text",                     :null => false
    t.boolean  "checked",        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_selections", ["basket_item_id"], :name => "index_attribute_selections_on_basket_item_id"

  create_table "features", :force => true do |t|
    t.integer  "product_id"
    t.string   "name",       :default => "",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ui_type",    :default => 0,    :null => false
    t.boolean  "required",   :default => true, :null => false
  end

  add_index "features", ["product_id"], :name => "index_attributes_on_product_id"

  create_table "forums", :force => true do |t|
    t.string  "name",       :default => "",    :null => false
    t.integer "website_id", :default => 0,     :null => false
    t.boolean "locked",     :default => false, :null => false
  end

  add_index "forums", ["website_id"], :name => "index_forums_on_website_id"

  create_table "images", :force => true do |t|
    t.integer  "website_id", :default => 0,  :null => false
    t.string   "name",       :default => "", :null => false
    t.string   "filename",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_lines", :force => true do |t|
    t.integer  "order_id",                                            :default => 0,   :null => false
    t.integer  "product_id",                                          :default => 0,   :null => false
    t.string   "product_sku",                                         :default => "",  :null => false
    t.string   "product_name",                                        :default => "",  :null => false
    t.decimal  "product_price",        :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.decimal  "tax_amount",           :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.integer  "quantity",                                            :default => 0,   :null => false
    t.decimal  "line_total",           :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feature_descriptions",                                                 :null => false
  end

  add_index "order_lines", ["order_id"], :name => "index_order_lines_on_order_id"
  add_index "order_lines", ["product_id"], :name => "index_order_lines_on_product_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.string   "order_number",                                                  :default => "",  :null => false
    t.string   "email_address",                                                 :default => "",  :null => false
    t.string   "full_name",                                                     :default => "",  :null => false
    t.string   "address_line_1",                                                :default => "",  :null => false
    t.string   "address_line_2",                                                :default => "",  :null => false
    t.string   "town_city",                                                     :default => "",  :null => false
    t.string   "county",                                                        :default => "",  :null => false
    t.string   "postcode",                                                      :default => "",  :null => false
    t.integer  "country_id",                                                    :default => 0,   :null => false
    t.string   "phone_number",                                                  :default => "",  :null => false
    t.decimal  "shipping_amount",                :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.string   "shipping_method",                                               :default => "",  :null => false
    t.integer  "status",                                                        :default => 0,   :null => false
    t.decimal  "total",                          :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",                                                    :default => 0,   :null => false
    t.integer  "basket_id"
    t.date     "preferred_delivery_date"
    t.string   "preferred_delivery_date_prompt"
    t.string   "preferred_delivery_date_format"
  end

  add_index "orders", ["basket_id"], :name => "index_orders_on_basket_id"
  add_index "orders", ["created_at"], :name => "index_orders_on_created_at"
  add_index "orders", ["email_address"], :name => "index_orders_on_email_address"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["website_id"], :name => "index_orders_on_website_id"

  create_table "pages", :force => true do |t|
    t.string   "title",       :default => "", :null => false
    t.string   "slug",        :default => "", :null => false
    t.integer  "website_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        :default => "", :null => false
    t.string   "keywords",    :default => "", :null => false
    t.string   "description", :default => "", :null => false
    t.text     "content",                     :null => false
    t.integer  "parent_id"
    t.integer  "position",    :default => 0,  :null => false
    t.integer  "image_id"
  end

  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"
  add_index "pages", ["website_id"], :name => "index_pages_on_website_id"

  create_table "payments", :force => true do |t|
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

  create_table "posts", :force => true do |t|
    t.integer  "topic_id",   :default => 0,  :null => false
    t.text     "content",                    :null => false
    t.string   "author",     :default => "", :null => false
    t.string   "email",      :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["topic_id"], :name => "index_posts_on_topic_id"

  create_table "preferred_delivery_date_settings", :force => true do |t|
    t.integer  "website_id",                     :default => 0,                         :null => false
    t.string   "prompt",                         :default => "Preferred delivery date", :null => false
    t.string   "date_format",                    :default => "%a %d %b"
    t.integer  "number_of_dates_to_show",        :default => 5,                         :null => false
    t.string   "rfc2822_week_commencing_day"
    t.integer  "number_of_initial_days_to_skip", :default => 1,                         :null => false
    t.string   "skip_after_time_of_day"
    t.boolean  "skip_bank_holidays",             :default => true,                      :null => false
    t.boolean  "skip_saturdays",                 :default => true,                      :null => false
    t.boolean  "skip_sundays",                   :default => true,                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferred_delivery_date_settings", ["website_id"], :name => "index_preferred_delivery_date_settings_on_website_id"

  create_table "product_group_placements", :force => true do |t|
    t.integer  "product_id",       :default => 0, :null => false
    t.integer  "product_group_id", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_groups", :force => true do |t|
    t.integer  "website_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_placements", :force => true do |t|
    t.integer  "page_id",    :default => 0, :null => false
    t.integer  "product_id", :default => 0, :null => false
    t.integer  "position",   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_placements", ["page_id"], :name => "index_product_placements_on_page_id"
  add_index "product_placements", ["product_id"], :name => "index_product_placements_on_product_id"

  create_table "products", :force => true do |t|
    t.integer  "website_id"
    t.string   "sku",                                                             :null => false
    t.string   "name",                                                            :null => false
    t.decimal  "price",          :precision => 10, :scale => 3, :default => 0.0,  :null => false
    t.integer  "image_id"
    t.text     "description",                                                     :null => false
    t.boolean  "in_stock",                                      :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_shipping",                                :default => true, :null => false
    t.text     "full_detail",                                                     :null => false
    t.integer  "tax_type",                                      :default => 1,    :null => false
  end

  create_table "quantity_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "quantity",                                  :default => 0,   :null => false
    t.decimal  "price",      :precision => 10, :scale => 3, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quantity_prices", ["product_id"], :name => "index_quantity_prices_on_product_id"

  create_table "topics", :force => true do |t|
    t.string   "topic",            :default => "", :null => false
    t.integer  "forum_id",         :default => 0,  :null => false
    t.integer  "posts_count",      :default => 0,  :null => false
    t.integer  "views",            :default => 0,  :null => false
    t.integer  "last_post_id",     :default => 0,  :null => false
    t.string   "last_post_author", :default => "", :null => false
    t.datetime "last_post_at",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  add_index "topics", ["last_post_at"], :name => "index_topics_on_last_post_at"

  create_table "users", :force => true do |t|
    t.string   "email",                 :default => "",    :null => false
    t.string   "name",                  :default => "",    :null => false
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "forgot_password_token", :default => "",    :null => false
    t.boolean  "admin",                 :default => false, :null => false
    t.integer  "manages_website_id",    :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "website_id",            :default => 0,     :null => false
  end

  add_index "users", ["website_id"], :name => "index_users_on_website_id"

  create_table "websites", :force => true do |t|
    t.string   "subdomain",                                                                         :null => false
    t.string   "domain",                                                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_analytics_code",                                          :default => "",    :null => false
    t.string   "name",                                                           :default => "",    :null => false
    t.string   "email",                                                          :default => "",    :null => false
    t.text     "css_url",                                                                           :null => false
    t.boolean  "use_default_css",                                                :default => false, :null => false
    t.boolean  "shop",                                                           :default => false, :null => false
    t.boolean  "rbswp_active",                                                   :default => false, :null => false
    t.string   "rbswp_installation_id",                                          :default => "",    :null => false
    t.string   "rbswp_payment_response_password",                                :default => "",    :null => false
    t.boolean  "rbswp_test_mode",                                                :default => false, :null => false
    t.boolean  "can_users_create_accounts",                                      :default => true,  :null => false
    t.boolean  "skip_payment",                                                   :default => false, :null => false
    t.boolean  "blog_id"
    t.decimal  "shipping_amount",                 :precision => 10, :scale => 3, :default => 0.0,   :null => false
    t.boolean  "private",                                                        :default => false, :null => false
    t.boolean  "accept_payment_on_account",                                      :default => false, :null => false
    t.string   "vat_number",                                                     :default => "",    :null => false
    t.boolean  "show_vat_inclusive_prices",                                      :default => false, :null => false
    t.text     "terms_and_conditions",                                                              :null => false
    t.string   "default_locale",                                                 :default => "en",  :null => false
    t.integer  "page_image_size",                                                :default => 400
    t.integer  "page_thumbnail_size",                                            :default => 200
    t.integer  "product_image_size",                                             :default => 400
    t.integer  "product_thumbnail_size",                                         :default => 200
    t.boolean  "render_blog_before_content",                                     :default => true,  :null => false
  end

end
