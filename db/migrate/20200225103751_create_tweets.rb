class CreateTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets do |t|
      t.text :tweetInfo, null: false
      t.string :userId, null: false, unique: true
      t.references :users_record, null: false, foreign_key: true
      t.timestamps
      t.index [:id, :users_record_id, :tweetInfo], name: "tweets_list_index"
    end
  end
end
