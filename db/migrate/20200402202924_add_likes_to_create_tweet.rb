class AddLikesToCreateTweet < ActiveRecord::Migration[6.0]
  def change
    add_column :tweets, :likes, :string, array:true, default:[]
  end
end
