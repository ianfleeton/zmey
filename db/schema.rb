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

ActiveRecord::Schema.define(:version => 20090728094438) do

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
  end

  create_table "images", :force => true do |t|
    t.integer  "website_id", :default => 0,  :null => false
    t.string   "name",       :default => "", :null => false
    t.string   "filename",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "pages", ["slug"], :name => "index_pages_on_slug"
  add_index "pages", ["website_id"], :name => "index_pages_on_website_id"

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
  end

  create_table "websites", :force => true do |t|
    t.string   "subdomain",                             :null => false
    t.string   "domain",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_analytics_code", :default => "", :null => false
    t.string   "name",                  :default => "", :null => false
    t.string   "email",                 :default => "", :null => false
  end

end
