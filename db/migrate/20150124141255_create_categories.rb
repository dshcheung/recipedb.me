class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :main_category
      t.text :main_category_url
      t.string :sub_category
      t.text :sub_category_url
      t.integer :scrape_category_status

      t.timestamps
    end
    add_index :categories, :main_category
    add_index :categories, :sub_category
  end
end
