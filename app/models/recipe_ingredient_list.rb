class RecipeIngredientList < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient

  validates_uniqueness_of :recipe_id, scope: :category_id
end
