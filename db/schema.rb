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

ActiveRecord::Schema.define(version: 20150124141305) do

  create_table "categories", force: true do |t|
    t.string   "main_category"
    t.text     "main_category_url"
    t.string   "sub_category"
    t.text     "sub_category_url"
    t.integer  "scrape_category_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["main_category"], name: "index_categories_on_main_category"
  add_index "categories", ["sub_category"], name: "index_categories_on_sub_category"

  create_table "domain_names", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredient_names", force: true do |t|
    t.string   "ingredient_sub_name"
    t.integer  "ingredient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", force: true do |t|
    t.integer  "ar_ingredient_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ingredients", ["ar_ingredient_code"], name: "index_ingredients_on_ar_ingredient_code"

  create_table "outside_profiles", force: true do |t|
    t.integer  "display_format"
    t.string   "username"
    t.string   "full_name"
    t.string   "site_name"
    t.string   "outside_profile_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipe_category_lists", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipe_category_lists", ["category_id"], name: "index_recipe_category_lists_on_category_id"
  add_index "recipe_category_lists", ["recipe_id", "category_id"], name: "index_recipe_category_lists_on_recipe_id_and_category_id"
  add_index "recipe_category_lists", ["recipe_id"], name: "index_recipe_category_lists_on_recipe_id"

  create_table "recipe_ingredient_lists", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "ingredient_id"
    t.integer  "amount_us"
    t.string   "unit_us"
    t.integer  "amount_metric"
    t.string   "unit_metric"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipe_ingredient_lists", ["ingredient_id"], name: "index_recipe_ingredient_lists_on_ingredient_id"
  add_index "recipe_ingredient_lists", ["recipe_id", "ingredient_id"], name: "index_recipe_ingredient_lists_on_recipe_id_and_ingredient_id"
  add_index "recipe_ingredient_lists", ["recipe_id"], name: "index_recipe_ingredient_lists_on_recipe_id"

  create_table "recipes", force: true do |t|
    t.integer  "user_id"
    t.integer  "outside_profile_id"
    t.integer  "domain_name_id"
    t.string   "url_code"
    t.string   "name"
    t.text     "description"
    t.text     "img_urls"
    t.text     "img_collection_url"
    t.integer  "scrape_collection_completed"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.integer  "ready_time"
    t.integer  "rest_time"
    t.integer  "original_servings_amount"
    t.string   "original_servings_type"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipes", ["name"], name: "index_recipes_on_name"
  add_index "recipes", ["outside_profile_id"], name: "index_recipes_on_outside_profile_id"
  add_index "recipes", ["user_id"], name: "index_recipes_on_user_id"

  create_table "user_bookmarks", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_bookmarks", ["recipe_id"], name: "index_user_bookmarks_on_recipe_id"
  add_index "user_bookmarks", ["user_id", "recipe_id"], name: "index_user_bookmarks_on_user_id_and_recipe_id"
  add_index "user_bookmarks", ["user_id"], name: "index_user_bookmarks_on_user_id"

  create_table "user_recipe_images", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_img_file_name"
    t.string   "user_img_content_type"
    t.integer  "user_img_file_size"
    t.datetime "user_img_updated_at"
  end

  add_index "user_recipe_images", ["recipe_id"], name: "index_user_recipe_images_on_recipe_id"
  add_index "user_recipe_images", ["user_id", "recipe_id"], name: "index_user_recipe_images_on_user_id_and_recipe_id"
  add_index "user_recipe_images", ["user_id"], name: "index_user_recipe_images_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username",                            null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username"

end
