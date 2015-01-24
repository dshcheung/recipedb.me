class Category < ActiveRecord::Base
  has_many :recipe_category_lists
  has_many :recipes, through: :recipe_category_lists

  validates_uniqueness_of :main_category, scope: :sub_category
end
