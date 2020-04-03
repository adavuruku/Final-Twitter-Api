class CreateUsersRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :users_records do |t|
      t.string :userFullName, null: false
      t.string :userId, null: false, unique: true
      t.string :userName, null: false, unique: true
      t.string :userEmail, null: false, unique: true
      t.string :userPhone
      t.string :userBio
      t.string :userLocation
      t.string :userWebsite
      t.text :password_digest
      t.timestamps
      t.index [:userId, :userName,:userEmail], name: "userd_record_list_index", unique:true
    end
  end
end
