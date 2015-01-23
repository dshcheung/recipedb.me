class CreateUserRecipeImages < ActiveRecord::Migration
  def change
    create_table :user_recipe_images do |t|
      t.integer :user_id
      t.integer :recipe_id
      t.timestamps
    end
    add_index :user_recipe_images, :user_id
    add_index :user_recipe_images, :recipe_id
    add_index :user_recipe_images, [:user_id, :recipe_id]
  end
end
