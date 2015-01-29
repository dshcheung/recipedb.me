class CreateRecipeIngredientLists < ActiveRecord::Migration
  def change
    create_table :recipe_ingredient_lists do |t|
      t.integer :recipe_id
      t.integer :ingredient_id
      t.integer :amount_us
      t.string :unit_us
      t.integer :amount_metric
      t.string :unit_metric
      t.string :display_name

      t.timestamps
    end
    add_index :recipe_ingredient_lists, :recipe_id
    add_index :recipe_ingredient_lists, :ingredient_id
    add_index :recipe_ingredient_lists, [:recipe_id, :ingredient_id]
  end
end
