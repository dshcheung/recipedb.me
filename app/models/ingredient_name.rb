class IngredientName < ActiveRecord::Base
  belongs_to :ingredients

  validates_uniqueness_of :sub_name, scope: :ingredient_id
end
