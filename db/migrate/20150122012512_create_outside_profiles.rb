class CreateOutsideProfiles < ActiveRecord::Migration
  def change
    create_table :outside_profiles do |t|
      t.integer :display_format #(1=ar_user, 2=full name, 3=sitename)
      t.string :username #(could be nil)
      t.string :full_name #(could be nil)
      t.string :site_name #(could be nil)
      t.string :outside_profile_url
      
      t.timestamps
    end
  end
end
