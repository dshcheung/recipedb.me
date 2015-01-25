class RecipeCategoryList < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :category

  validates_uniqueness_of :recipe_id, scope: :category_id
end
