class CreateFollowers < ActiveRecord::Migration[6.0]
  def change
    create_table :followers do |t|
      t.string :userId, null: false
      t.string :followerId, null: false
      t.references :users_record, null: false, foreign_key: true
      t.timestamps
      t.index [:id, :users_record_id], name: "followers_list_index"
    end
  end
end
