class IngredientName < ActiveRecord::Base
  belongs_to :ingredients

  validates_uniqueness_of :recipe_ingredient_sub_name, scope: :ingredient_id
end
