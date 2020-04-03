class RenameUserRecords < ActiveRecord::Migration[6.0]
  def change
    rename_column :users_records, :userFullName, :userfullname
    rename_column :users_records, :userId, :userid
    rename_column :users_records, :userName, :username
    rename_column :users_records, :userEmail, :useremail
    rename_column :users_records, :userPhone, :userphone
    rename_column :users_records, :userBio, :userbio
    rename_column :users_records, :userLocation, :userlocation
    rename_column :users_records, :userWebsite, :userwebsite
  end
end
