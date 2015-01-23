class Ingredient < ActiveRecord::Base
  has_many :recipe_ingredient_lists
  has_many :recipes, through: :recipe_ingredient_lists
  has_many :ingredient_names

  validates :ar_ingredient_code, uniqueness: true
end
