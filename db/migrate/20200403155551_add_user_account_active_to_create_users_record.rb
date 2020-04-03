class AddUserAccountActiveToCreateUsersRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :users_records, :admin, :boolean, default:false
    add_column :users_records, :active, :boolean, default:true
  end
end
