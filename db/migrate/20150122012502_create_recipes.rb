class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.integer :user_id #(could be nil)
      t.integer :outside_profile_id #(could be nil)
      t.string :domain_name_id #(unique with recipe_url_code)
      t.string :recipe_url_code #(unique with domain_name_id)
      t.string :recipe_name
      t.text :recipe_description
      t.text :recipe_img_urls #(serialize array of images urls)
      t.text :recipe_img_collection_url
      t.integer :scrape_collection_completed
      t.integer :recipe_prep_time
      t.integer :recipe_cook_time
      t.integer :recipe_ready_time
      t.integer :recipe_rest_time
      t.integer :recipe_original_servings_amount
      t.string :recipe_original_servings_type
      t.text :recipe_instructions

      t.timestamps
    end
    
    add_index :recipes, :user_id
    add_index :recipes, :outside_profile_id
    add_index :recipes, :recipe_name
  end
end
