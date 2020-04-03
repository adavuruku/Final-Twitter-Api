class Tweet < ApplicationRecord
    belongs_to :users_record
    has_many_attached :tweetAttachments
    validates :userid, presence: true, on: :create
end
