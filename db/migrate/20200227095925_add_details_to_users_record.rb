class AddDetailsToUsersRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :users_records, :dob, :date
  end
end
