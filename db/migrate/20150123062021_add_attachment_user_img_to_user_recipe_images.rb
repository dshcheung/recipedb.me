class AddAttachmentUserImgToUserRecipeImages < ActiveRecord::Migration
  def self.up
    change_table :user_recipe_images do |t|
      t.attachment :user_img
    end
  end

  def self.down
    remove_attachment :user_recipe_images, :user_img
  end
end
