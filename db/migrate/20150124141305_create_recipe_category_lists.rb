class CreateRecipeCategoryLists < ActiveRecord::Migration
  def change
    create_table :recipe_category_lists do |t|

      t.integer :recipe_id
      t.integer :category_id

      t.timestamps
    end
    add_index :recipe_category_lists, :recipe_id
    add_index :recipe_category_lists, :category_id
    add_index :recipe_category_lists, [:recipe_id, :category_id]
  end
end
