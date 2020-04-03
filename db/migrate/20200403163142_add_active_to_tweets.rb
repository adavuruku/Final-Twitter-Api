class AddActiveToTweets < ActiveRecord::Migration[6.0]
  def change
    add_column :tweets, :active, :boolean, default:true
  end
end
