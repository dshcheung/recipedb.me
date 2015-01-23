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

ActiveRecord::Schema.define(version: 20150123014304) do

  create_table "ingredient_names", force: true do |t|
    t.string   "recipe_ingredient_sub_name"
    t.integer  "ingredient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", force: true do |t|
    t.integer  "ar_ingredient_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outside_profiles", force: true do |t|
    t.integer  "display_format"
    t.string   "username"
    t.string   "full_name"
    t.string   "site_name"
    t.string   "outside_profile_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipe_ingredient_lists", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "ingredient_id"
    t.integer  "recipe_amount_us"
    t.string   "recipe_unit_us"
    t.integer  "recipe_amount_metric"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: true do |t|
    t.integer  "user_id"
    t.integer  "outside_profile_id"
    t.string   "domain_name_id"
    t.string   "recipe_url_code"
    t.string   "recipe_name"
    t.text     "recipe_description"
    t.text     "recipe_img_url"
    t.text     "recipe_img_collection_url"
    t.integer  "scrape_collection_completed"
    t.integer  "recipe_prep_time"
    t.integer  "recipe_cook_time"
    t.integer  "recipe_ready_time"
    t.integer  "recipe_rest_time"
    t.integer  "recipe_original_servings_amount"
    t.string   "recipe_original_servings_type"
    t.text     "recipe_instructions"
    t.text     "recipe_ingredients"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
