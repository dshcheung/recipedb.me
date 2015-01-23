class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :ar_ingredient_code

      t.timestamps
    end
  end
end
