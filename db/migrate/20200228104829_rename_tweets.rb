class RenameTweets < ActiveRecord::Migration[6.0]
  def change
    rename_column :tweets, :tweetInfo, :tweetinfo
    rename_column :tweets, :userId, :userid
  end
end
