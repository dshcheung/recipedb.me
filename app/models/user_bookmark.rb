class UserBookmark < ActiveRecord::Base
  belongs_to :user
  has_one :recipe

  validates_uniqueness_of :recipe_id, scope: :user_id
end
