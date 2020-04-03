class RenameFollowers < ActiveRecord::Migration[6.0]
  def change
    rename_column :followers, :userId, :userid
    rename_column :followers, :followerId, :followerid
  end
end
