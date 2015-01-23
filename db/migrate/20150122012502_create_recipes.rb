class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.integer :user_id #(could be nil)
      t.integer :outside_profile_id #(could be nil)
      t.integer :domain_name_id #(unique with url_code)
      t.string :url_code #(unique with domain_name_id)
      t.string :name
      t.text :description
      t.text :img_urls #(serialize array of images urls)
      t.text :img_collection_url
      t.integer :scrape_collection_completed
      t.integer :prep_time
      t.integer :cook_time
      t.integer :ready_time
      t.integer :rest_time
      t.integer :original_servings_amount
      t.string :original_servings_type
      t.text :instructions

      t.timestamps
    end
    
    add_index :recipes, :user_id
    add_index :recipes, :outside_profile_id
    add_index :recipes, :name
  end
end
