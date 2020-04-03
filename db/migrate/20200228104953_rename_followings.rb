class RenameFollowings < ActiveRecord::Migration[6.0]
  def change
    rename_column :followings, :userId, :userid
    rename_column :followings, :followingId, :followingid
  end
end
