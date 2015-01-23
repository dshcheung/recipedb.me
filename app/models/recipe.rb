class Recipe < ActiveRecord::Base

  serialize :img_urls, Array
  serialize :instructions, Array 

  # has_many :recipe_category_lists
  # has_many :categories, through: :recipe_category_lists
  has_many :recipe_ingredient_lists
  has_many :ingredients, through: :recipe_ingredient_lists
  belongs_to :user
  belongs_to :outside_profile
  belongs_to :domain_name
  has_many :user_recipe_images

  validates_uniqueness_of :url_code, scope: :domain_name_id
end