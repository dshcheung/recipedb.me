class CreateUserBookmarks < ActiveRecord::Migration
  def change
    create_table :user_bookmarks do |t|
      t.integer :user_id
      t.integer :recipe_id

      t.timestamps
    end
    add_index :user_bookmarks, :user_id
    add_index :user_bookmarks, :recipe_id
    add_index :user_bookmarks, [:user_id, :recipe_id]
  end
end
