class UserRecipeImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :recipe

  has_attached_file :user_img, 
  :storage => :s3, 
  :s3_credentials => Proc.new{|a| a.instance.s3_credentials }, 
  :styles => { :medium => "300x300>", :small => "150x150>" }, 
  :default_url => "http://s3.amazonaws.com/boxful-admin/image/boximg2.png"

  validates_attachment_content_type :user_img, :content_type => /\Aimage\/.*\Z/

  def s3_credentials
    {:bucket => ENV['S3_BUCKET'], 
      :access_key_id => ENV['ACCESS_KEY_ID'], 
      :secret_access_key =>ENV['SECRET_ACCESS_KEY']}
  end
end
