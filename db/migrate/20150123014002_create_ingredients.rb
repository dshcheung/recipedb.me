class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :ar_ingredient_code

      t.timestamps
    end
    add_index :ingredients, :ar_ingredient_code
  end
end
