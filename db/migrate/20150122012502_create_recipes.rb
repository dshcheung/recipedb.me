class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.integer :user_id #(could be nil)
      t.integer :outside_profile_id #(could be nil)
      t.string :domain_name_id #(unique with recipe_url_code)
      t.string :recipe_url_code #(unique with domain_name_id)
      t.string :recipe_name
      t.text :recipe_description
      t.string :recipe_video_url #(could be nil)
      t.string :recipe_img_url #(serialize array of images urls)
      t.integer :recipe_original_servings
      t.text :recipe_instructions

      t.timestamps
    end
  end
end
