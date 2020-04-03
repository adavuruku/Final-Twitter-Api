class CreateRetweets < ActiveRecord::Migration[6.0]
  def change
    create_table :retweets do |t|
      t.string :userid, null: false, unique: true
      t.references :users_record, null: false, foreign_key: true
      t.integer 'allretweet', array: true
      t.timestamps
    end
  end
end
