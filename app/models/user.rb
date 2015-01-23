class User < ActiveRecord::Base
  has_many :recipes
  has_many :user_bookmarks
  has_many :user_recipe_images

  validates :username, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
