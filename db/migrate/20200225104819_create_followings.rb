class CreateFollowings < ActiveRecord::Migration[6.0]
  def change
    create_table :followings do |t|
      t.string :userId, null: false
      t.string :followingId, null: false
      t.references :users_record, null: false, foreign_key: true
      t.timestamps
      t.index [:id, :users_record_id], name: "following_list_index"
    end
  end
end
